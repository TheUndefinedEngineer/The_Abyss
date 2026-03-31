*28-03-2026* 

## Introduction

- Manages CPU AHB I-Code and D-Code access to the flash.
- Erase and Program operations of flash memory.
- Read & Write protection.

> [!important] Key Insight
> The flash memory interface accelerates code execution with a system of instruction prefetch and cache lines.

---
## Main Features

- Flash memory read operations
- Flash memory program/erase operations
- Read / write protections
- Prefetch on I-Code
- 64 cache lines of 128 bits on I-Code
- 8 cache lines of 128 bits on D-Code

![[flash interface.png]]
*shows the flash memory interface connection inside the system architecture.*

---
## Embedded Flash Memory

| Feature               | Detail                                                       |
| --------------------- | ------------------------------------------------------------ |
| **Capacity**          | 256 KB (xB/C variants) or 512 KB (xD/E variants)             |
| **Read width**        | 128-bit bus — fetches 16 bytes per cycle for speed           |
| **Write granularity** | Byte (8b), half-word (16b), word (32b), or double-word (64b) |
| **Erase granularity** | Sector-level or full chip (mass erase)                       |

Even though the CPU is 32-bit, the Flash interface prefetches 4 instructions (128-bits) at once, which is why the ART **(Adaptive Real-Time)** Accelerator can make Flash feel as fast as zero-wait-state SRAM at lower clock speeds.

### Memory Organization — The 4 Regions

#### 1. Main Memory Block (firmware lives here)

This is where the compiled `.bin`/`.elf` gets flashed.

```
STM32F401xB/C (256 KB total):

Sector 0 →  16 KB   ← startup code, vector table usually here
Sector 1 →  16 KB
Sector 2 →  16 KB
Sector 3 →  16 KB
Sector 4 →  64 KB
Sector 5 → 128 KB
           ------
Total     = 256 KB
```

```
STM32F401xD/E (512 KB total):

Sector 0 →  16 KB
Sector 1 →  16 KB
Sector 2 →  16 KB
Sector 3 →  16 KB
Sector 4 →  64 KB
Sector 5 → 128 KB
Sector 6 → 128 KB
Sector 7 → 128 KB
           ------
Total     = 512 KB
```

> [!warning] **Caution:** 
> Flash erase is **sector-granular**, not byte-granular. If you want to update anything in Sector 2, the entire 16 KB sector gets wiped first. This is why wear-leveling matters for frequent Flash writes (like saving config data).

#### 2. System Memory (ROM — factory programmed by ST)

- System memory - 30 bytes.
- System memory is where the device boots into System memory boot mode.
- This is **read-only** and contains ST's **bootloader** firmware.
- Activated by pulling `BOOT0` pin HIGH on reset.
- Allows flashing firmware over **UART, USB, SPI, I2C** without a debugger — useful for field updates.
- It can't erased or modified.

#### 3. OTP — One-Time Programmable Bytes (512 bytes)

- 512 bytes split into **16 blocks of 32 bytes** each.
- Once a bit is written to `0`, it **can never go back to `1`** — hence "one-time".
- Typical uses: burning a serial number, hardware revision ID, calibration constants, or a MAC address into the device permanently.
- Each block has a **corresponding lock byte** (the 16 extra bytes mentioned). Writing `0x00` to a lock byte permanently **freezes that entire 32-byte block**.

#### 4. Option Bytes (16 bytes, configuration, not code)

These are special registers stored in Flash that configure **chip-level behaviour**:

| Option                     | Purpose                                                                  |
| -------------------------- | ------------------------------------------------------------------------ |
| **Read Protection (RDP)**  | Level 0 (open), Level 1 (no debug readback), Level 2 (permanent lock)    |
| **Write Protection (WRP)** | Prevent specific sectors from being erased/written                       |
| **BOR Level**              | Brown-Out Reset threshold — resets chip if VDD drops below a set voltage |
| **Watchdog mode**          | Hardware (always running) vs Software (enable it in code)                |
| **Standby/Stop reset**     | Optionally reset the chip when exiting low-power modes                   |

> [!warning] **Caution:**
> Setting RDP Level 2 is **irreversible** — it permanently disables JTAG/SWD and locks out all debug access. Used for production security.

### Low-Power Modes

Flash power behaviour changes in low-power modes:

- **Sleep mode** — Flash stays powered, no impact.
- **Stop mode** — Flash is powered down; on wake, there's a small latency before code can run again.
- **Standby mode** — Flash is fully off; essentially a near-reset on wake.

This matters for **Bike Black Box** project - [[Bike Black Box]]
### Quick Mental Model

```
+------------------+
|   Main Flash     |  ← firmware (.text, .rodata, vectors)
|  (256/512 KB)    |
+------------------+
|  System Memory   |  ← ST's bootloader (ROM, read-only)
+------------------+
|   OTP (512 B)    |  ← Permanent device identity/calibration
+------------------+
|  Option Bytes    |  ← Chip security & behavior config
+------------------+
```

---
*31/03/2026*

## Read Interface

### Relation between CPU clock frequency and flash memory read time

Flash memory has a **fixed physical access time** (~30 ns on the STM32F4 - *need to verify*). The CPU presents an address on the bus, and the flash needs that much *wall-clock time* before the data on its output lines is valid.

A wait state is **not** a delay inserted before the read starts. The read begins immediately when the address is presented.

> [!important] Precise Definition
> A wait state = an **extra clock cycle the CPU is held frozen on the bus**, giving flash enough wall-clock time to produce valid data after the read request is issued.

So the sequence for 2 WS at 84 MHz looks like this:

| Cycle | Elapsed Time | What's Happening |
|-------|-------------|-----------------|
| 1 | ~11.9 ns | Address presented, flash starts reading |
| 2 | ~23.8 ns | Flash still working (CPU stalled) |
| 3 | ~35.7 ns | Data valid ✓ (flash access time ~30 ns covered) |

At **0 WS**, the flash finishes within a single clock period — no stalling needed at all.

Flash access time is fixed. CPU cycle duration is not.

$$t_{cycle} = \frac{1}{f_{HCLK}}$$

At higher frequencies, each cycle is shorter — so more cycles are needed to cover the same ~30 ns access time.
```
Flash access time ≈ 30 ns

@ 16 MHz → 1 cycle = 62.5 ns → 0 WS (one cycle covers it)
@ 60 MHz → 1 cycle = 16.7 ns → 1 WS (2 cycles = 33.3 ns ✓)
@ 84 MHz → 1 cycle = 11.9 ns → 2 WS (3 cycles = 35.7 ns ✓)
```

| Wait States (WS)        | 2.7V – 3.6V        | 2.4V – 2.7V        | 2.1V – 2.4V        | 1.71V – 2.1V       |
|-------------------------|--------------------|--------------------|--------------------|--------------------|
| 0 WS (1 CPU cycle)      | 0 < HCLK ≤ 30      | 0 < HCLK ≤ 24      | 0 < HCLK ≤ 18      | 0 < HCLK ≤ 16      |
| 1 WS (2 CPU cycles)     | 30 < HCLK ≤ 60     | 24 < HCLK ≤ 48     | 18 < HCLK ≤ 36     | 16 < HCLK ≤ 32     |
| 2 WS (3 CPU cycles)     | 60 < HCLK ≤ 84     | 48 < HCLK ≤ 72     | 36 < HCLK ≤ 54     | 32 < HCLK ≤ 48     |
| 3 WS (4 CPU cycles)     | 72 < HCLK ≤ 84     | 54 < HCLK ≤ 72     | 48 < HCLK ≤ 64     | -                  |
| 4 WS (5 CPU cycles)     | -                  | -                  | 72 < HCLK ≤ 84     | 64 < HCLK ≤ 80     |
| 5 WS (6 CPU cycles)     | -                  | -                  | -                  | 80 < HCLK ≤ 84     |
The wait states(WS) is the LATENCY which has to be programmed in the flash access control register **(FLASH_ACR)** according to the clock **HCLK** and the supply voltage.

> [!note] Why does voltage matter?
> Lower supply voltage slows down the flash sense amplifiers, increasing the physical access time. More wait states are needed to compensate — the CPU has to wait longer for the same read to complete.

**Q. Why do both VOS entries say "maximum"? Are they the same thing?**

This tripped me up — both VOS lines use the word "maximum" but they're describing completely different limits.
```
- VOS[1:0] = 0x01 → max fHCLK = 60 MHz
- VOS[1:0] = 0x10 → max fHCLK = 84 MHz
```

**VOS(Voltage Output Scale) is the internal core voltage regulator setting** — not the supply voltage on the pin. It controls the voltage the regulator feeds to the CPU core logic itself.

| VOS Setting | Core Voltage | Effect | CPU Ceiling |
|-------------|-------------|--------|-------------|
| 0x01 (Scale 2) | Lower | Logic switches slower, less power | 60 MHz |
| 0x10 (Scale 1) | Higher | Logic switches faster | 84 MHz |

> [!important] Two separate constraints
> - **Wait state table** → governs flash *read timing* (bus interface)
> - **VOS limit** → governs the CPU *core itself* (internal logic switching speed)
> 
> Above the VOS ceiling, setup/hold timing violations occur **inside the CPU** — not just in flash. The whole system becomes unreliable.

Both are called "maximum" because both are hard silicon limits — just for different parts of the chip.

If LATENCY is too low for the running clock speed, the CPU latches flash data before it's valid — **no fault is raised, it just executes corrupted reads.**

After Reset State:
- HCLK = **16 MHz**
- LATENCY = **0 WS**

This is safe per the table (16 MHz at any voltage = 0 WS). The moment PLL is configured to push HCLK higher, LATENCY must be set first.

---
### Adaptive real-time memory accelerator (ART Accelerator™)

The STM32F4's Cortex-M4 core can run at 84 MHz, but flash memory is slow relative to that speed — requiring up to 2–5 wait states depending on voltage. Without any mitigation, the CPU would be stalled on nearly every instruction fetch.

The ART Accelerator bridges this gap so that, in practice, **program execution from flash at 84 MHz benchmarks equivalent to 0 wait state execution** (per CoreMark).

It has three distinct mechanisms to achieve this:
#### Mechanism 1 — Instruction Prefetch

Flash memory is not read one instruction at a time. **Every flash read operation fetches 128 bits at once.** That maps to:
- **4 × 32-bit instructions** (Thumb-2 / ARM encoding), or
- **8 × 16-bit instructions** (Thumb encoding)

This means that for sequential code, once a 128-bit line is fetched, the CPU has enough instructions to keep busy for at least 4 cycles before needing the next fetch. That's the natural window where the *next* prefetch can happen in the background.

**Q. How Prefetch Works?**

Without prefetch:
```
Cycle 1-3:  CPU requests line A → stalled for 3 WS
Cycle 4:    CPU executes inst 1 from line A
Cycle 5:    CPU executes inst 2 from line A
Cycle 6:    CPU executes inst 3 from line A
Cycle 7:    CPU executes inst 4 from line A
Cycle 8-10: CPU requests line B → stalled again for 3 WS
...
```

With prefetch enabled (PRFTEN bit in FLASH_ACR):
```
Cycle 1-3:  CPU requests line A → stalled for 3 WS
Cycle 4:    CPU executes inst 1 from line A
            [prefetch of line B starts in background on I-Code bus]
Cycle 5:    CPU executes inst 2 | line B fetch in progress
Cycle 6:    CPU executes inst 3 | line B fetch in progress
Cycle 7:    CPU executes inst 4 | line B fetch complete ✓
Cycle 8:    CPU executes inst 1 from line B — no stall
```

> [!important] Prefetch only helps sequential code
> The prefetch queue reads the *next sequential* line. If the CPU branches to a non-sequential address, the prefetched line is the wrong one — a **miss** — and the penalty is at least equal to the number of wait states.

> [!note] Enable condition
> Prefetch is only useful when **at least 1 WS** is configured. At 0 WS, flash keeps up with the CPU anyway — prefetch adds no benefit there.

**Register:** Set `FLASH_ACR.PRFTEN = 1` to enable.

---
#### Mechanism 2 — Instruction Cache (I-Cache)

Prefetch helps sequential execution. The instruction cache handles the branch/jump case.

**Q. How It Works?**

- **64 lines × 128 bits** = 1 KB of instruction cache
- On every cache miss, the fetched 128-bit line is **copied into the cache**
- On subsequent accesses to cached lines, data is returned **with zero delay** (no wait states, regardless of LATENCY setting)
- When all 64 lines are full, the **LRU (Least Recently Used)** policy evicts the line that was accessed least recently

> [!tip] Best use case: loops
> A tight loop that fits within cached lines will execute entirely from cache after
> the first pass — subsequent iterations pay zero wait states. This is the primary
> reason real-world performance at 84 MHz approaches the 0 WS benchmark.

**Register:** Set `FLASH_ACR.ICEN = 1` to enable.

---
#### Mechanism 3 — Data Cache (D-Cache)

Literal pools are constants embedded in the code by the compiler (immediate values too large to encode directly in an instruction). They are fetched from flash through the **D-Code bus** during the CPU pipeline's *execute* stage.

This is a problem because:
- The CPU pipeline stalls until the literal pool value is returned from flash
- It comes through a different bus (D-Code) than instructions (I-Code)
- It happens mid-execution, not during fetch

**Bus Priority:**
To reduce this stall, **D-Code bus accesses have priority over I-Code bus accesses** on the AHB data bus. The data fetch completes as fast as possible, unblocking the pipeline sooner.

**Data Cache:**
For frequently accessed literal pools and data constants, the data cache retains recently fetched values:
- **8 lines × 128 bits** = 128 bytes of data cache
- Same miss/fill/LRU behaviour as instruction cache
- Returns cached data **with zero delay**

> [!warning] Limitation
> Data in the **user configuration sector** is not cacheable.

**Register:** Set `FLASH_ACR.DCEN = 1` to enable.

---
#### Summary: Three Buses, Three Mechanisms

| Mechanism            | Bus    | Helps With               | Cache Size   | Enable Bit |
| -------------------- | ------ | ------------------------ | ------------ | ---------- |
| Instruction Prefetch | I-Code | Sequential code          | — (queue)    | `PRFTEN`   |
| Instruction Cache    | I-Code | Branches, loops          | 64 × 128-bit | `ICEN`     |
| Data Cache           | D-Code | Literal pools, constants | 8 × 128-bit  | `DCEN`     |

All three are typically enabled together when configuring the system clock. Set these *along with* LATENCY before switching to PLL.

---





---
## !
Sources:
1. RM0368 Rev 6 — Section 3: Embedded Flash Memory Interface

Tags: #microcontroller #concept 