*02-05-2026* 

> [!important] `objdump -h` is an **X-ray of your ELF file** — it shows every section, its size, where it will live in memory, and what properties it has before the linker places it.

---
## The Output We're Analyzing

```
Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00000014  00000000  00000000  00000034  2**1
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .data         00000000  00000000  00000000  00000048  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000000  00000000  00000000  00000048  2**0
                  ALLOC
  3 .isr_vector   00000120  00000000  00000000  00000048  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, DATA
  4 .comment      00000027  00000000  00000000  00000168  2**0
                  CONTENTS, READONLY
  5 .ARM.attributes 0000002e  00000000  00000000  0000018f  2**0
                  CONTENTS, READONLY
```

> [!warning] **Key observation:** All VMAs are `0x0000 0000`. This is a **relocatable object file** (`.o`), NOT a final linked binary. Addresses are not assigned yet — that's the linker's job.

---
## Column-by-Column Breakdown

### `Idx` — Section Index

Just a sequential number. The linker uses the section name, not this index. Zero-based.

### `Name` — Section Name

The identifier used by the linker script to route this section to a memory region.

|Name|Meaning|
|---|---|
|`.text`|Compiled machine code (your functions)|
|`.data`|Initialized global/static variables|
|`.bss`|Zero-initialized global/static variables|
|`.isr_vector`|Interrupt Service Routine vector table|
|`.comment`|Compiler metadata string (not loaded to chip)|
|`.ARM.attributes`|CPU architecture info for the toolchain|

### `Size` — Section Size in Bytes (hex)

|Section|Hex Size|Decimal|What it means|
|---|---|---|---|
|`.text`|`0x14`|20 bytes|10 Thumb-2 instructions (2 bytes each) — very small file|
|`.data`|`0x00`|0|No initialized global variables|
|`.bss`|`0x00`|0|No zero-initialized variables|
|`.isr_vector`|`0x120`|**288 bytes**|72 entries × 4 bytes each (Cortex-M4 vector table)|
|`.comment`|`0x27`|39 bytes|GCC version string|
|`.ARM.attributes`|`0x2e`|46 bytes|ARM arch metadata|

> 📖 **RM0368 §10 / Cortex-M4 TRM** — The Cortex-M4 vector table starts with the initial Stack Pointer value at offset `0x0000`, then 15 system exception vectors, then up to 240 IRQ vectors. On STM32F401, `0x120` = 72 words = the full table for this device.


### `VMA` — Virtual Memory Address

The address the **CPU will see** at runtime. All zeros here because **this is an object file** — the linker hasn't assigned real addresses yet. After linking, `.text` will get `0x0800 0000`, `.isr_vector` will get `0x0800 0000` (it goes first!), etc.

```
Before linking (.o file):   VMA = 0x00000000  ← placeholder
After linking (.elf file):  VMA = 0x08000000  ← real Flash address
```

### `LMA` — Load Memory Address

The address where the section's **raw bytes physically live** (e.g., in Flash). For most sections LMA == VMA. The key exception is `.data`:

```
.data:  LMA = 0x08001234  (stored in Flash)
        VMA = 0x20000000  (copied to SRAM at boot by startup code)
```

In our object file, both are `0` — again, not yet linked.

### `File off` — File Offset

The byte offset inside the `.o` or `.elf` file where this section's raw bytes begin. Useful for `dd` or hex dump debugging. Not relevant at runtime.

### `Algn` — Alignment

`2**N` means the section must start at an address that is a multiple of `2^N`.

|Section|Algn|2^N|Reason|
|---|---|---|---|
|`.text`|`2**1`|2 bytes|Thumb-2 instructions are 2-byte aligned|
|`.data`|`2**0`|1 byte|No alignment requirement|
|`.bss`|`2**0`|1 byte|No alignment requirement|
|`.isr_vector`|`2**2`|**4 bytes**|Each vector entry is a 32-bit word — must be word-aligned|

> 📖 **RM0368 §2.2** — The STM32 memory is little-endian and word-addressed (32-bit). Misaligned word accesses generate a HardFault on Cortex-M4 (unless unaligned access is enabled in the MPU).

---
## The Flags — What They Mean

Each section has a set of flags that tell the linker (and loader) how to treat it.

|Flag|Meaning|
|---|---|
|`CONTENTS`|Section has actual bytes in the file (vs. `ALLOC`-only)|
|`ALLOC`|Reserve space in memory at runtime|
|`LOAD`|Copy these bytes from file to memory (Flash programming)|
|`READONLY`|Cannot be written at runtime|
|`CODE`|Contains executable instructions|
|`DATA`|Contains data (not instructions)|
|`RELOC`|Contains **relocation entries** — addresses need to be patched by linker|

---
## Section-by-Section Analysis

### `.text` — `CONTENTS, ALLOC, LOAD, READONLY, CODE`

Your compiled functions. 20 bytes (10 Thumb-2 instructions).

- `READONLY` + `CODE` → goes to Flash
- `LOAD` → the bytes get programmed into Flash
- No `RELOC` → all addresses within `.text` are already resolved (or: this object has no external calls yet)

### `.data` — `CONTENTS, ALLOC, LOAD, DATA`

Size is **zero** — this file has no initialized globals. The section exists as a placeholder.

- `LOAD` → would be programmed into Flash (init values)
- At boot, startup code copies from Flash LMA → SRAM VMA
- No `READONLY` → lives in SRAM at runtime (writable)

### `.bss` — `ALLOC` only

Size is **zero** — no zero-initialized globals. Only `ALLOC`, no `CONTENTS` or `LOAD`:

- No bytes in the file — the section is just a reservation of SRAM space
- Startup code (`memset` to 0) fills this region before `main()`
- No `LOAD` → nothing to program into Flash; the linker just notes how much SRAM to zero

### `.isr_vector` — `CONTENTS, ALLOC, LOAD, RELOC, DATA`

This is the **most important section** for bare-metal STM32. 288 bytes = 72 × 4-byte entries.

```
Offset  Content
0x0000  Initial Stack Pointer (MSP)    ← must point to top of SRAM
0x0004  Reset_Handler address          ← first instruction after reset
0x0008  NMI_Handler
0x000C  HardFault_Handler
...
0x0120  (end of table for STM32F401)
```

> 📖 **RM0368 §2.4 Boot Configuration** — After reset, the CPU fetches the initial Stack Pointer from `0x0000 0000` and the Reset Handler from `0x0000 0004`. When booting from Flash, `0x0000 0000` is aliased to `0x0800 0000`. So `.isr_vector` **must be the very first thing in Flash**.

The `RELOC` flag means some addresses in this table (like `Reset_Handler`) are not yet final — the linker will **patch** them in once it knows where every function lands.

### `.comment` — `CONTENTS, READONLY`

A GCC-generated string like `"GCC: (arm-none-eabi) 12.3.1"`. 39 bytes.

- No `ALLOC` → **never loaded into the MCU's memory**
- Pure metadata for humans and tools
- The linker will strip this from the final binary (or keep it in the ELF but not in the `.bin`)

### `.ARM.attributes` — `CONTENTS, READONLY`

ARM-specific metadata: CPU architecture (Cortex-M4), thumb ISA, FPU presence, ABI version.

- No `ALLOC` → never on the chip
- Used by the linker to catch mismatches (e.g., linking a Cortex-M0 object into a Cortex-M4 project → error)

---
## The Big Picture: What Happens Next (Linking)

This `.o` file is an **intermediate product**. The linker will:

1. **Collect** all `.o` files and libraries
2. **Apply relocations** — patch all the `RELOC` addresses (e.g., fill in `Reset_Handler`'s real address in `.isr_vector`)
3. **Assign VMAs and LMAs** using the linker script
4. **Place `.isr_vector` first** in Flash (at `0x0800 0000`)
5. **Place `.text` after** `.isr_vector`
6. **Output a final `.elf`** where all VMAs are real addresses

The resulting memory layout on STM32F401:

```
Flash (0x0800 0000)
├── .isr_vector   [0x0800 0000 .. 0x0800 011F]  ← 288 bytes
├── .text         [0x0800 0120 .. 0x0800 0133]  ← 20 bytes
└── .data (init)  [0x0800 0134 .. ...]          ← empty here

SRAM (0x2000 0000)
├── .data (copy)  [0x2000 0000 .. ...]          ← empty here
├── .bss          [0x2000 0000 .. ...]          ← empty here
├── Heap          ↑ grows up
└── Stack         ↓ grows down from top of SRAM
```

---
## Quick Reference Cheat Sheet

```
Flag        = Meaning
─────────────────────────────────────────────────
CONTENTS    → has bytes in the .o file
ALLOC       → needs memory at runtime
LOAD        → gets programmed into Flash
READONLY    → write = HardFault
CODE        → executable (I-bus / prefetch cache)
DATA        → data (D-bus access)
RELOC       → linker must patch addresses

VMA = 0     → not linked yet (object file, not ELF)
.bss        → ALLOC only, no CONTENTS (zeros = no storage)
.isr_vector → must land at Flash base (0x0800 0000 on STM32)
.comment    → no ALLOC = never on the chip
```

---
## Related Notes

- [[MCU Linker Scripts]]
- [[MCU Startup File from Scratch]]



---
## !
Sources:
1. 

Tags: #reference #microcontroller 