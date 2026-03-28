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

Even though the CPU is 32-bit, the Flash interface prefetches 4 instructions (128-bits) at once, which is why the ART Accelerator **(Adaptive Real-Time)** can make Flash feel as fast as zero-wait-state SRAM at lower clock speeds.

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

This matters for your **Bike Black Box** project - [[Bike Black Box]]
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





Sources:
1. https://claude.ai/share/06bc1916-5666-4ed2-bb1e-7c850f5076c2

Tags: #microcontroller #concept 