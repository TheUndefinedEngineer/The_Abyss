*2026-03-26* 
## What is Bit-Banding?

Bit-banding is a memory-mapping technique in ARM Cortex-M microcontrollers that allows **atomic read-modify-write access to individual bits** using regular 32-bit memory operations.

---
## The Problem It Solves

Normally, to set a single bit you do:

```c
REG |= (1 << 3);  // Step 1: Read → Step 2: Modify → Step 3: Write
```

This is **non-atomic** — an interrupt firing between steps can corrupt other bits. Bit-banding eliminates this risk by making a single-bit change a single hardware operation.

---
## The Key Idea

- The original **1 MB region** holds your actual data (variables, registers)
- Each bit in this region gets its own dedicated **32-bit word** in the alias region
- Writing `1` or `0` to that alias word sets or clears exactly that one bit — atomically
- Its different from bit masking.

### Why 1 MB expands to 32 MB

|Fact|Value|
|---|---|
|Bits in 1 MB|8,388,608 bits|
|Alias bytes per bit|4 bytes (one 32-bit word)|
|Total alias space|8,388,608 × 4 = **32 MB**|

> **Each byte in the 1 MB region expands to 32 bytes in the alias** (8 bits × 4 bytes = 32 bytes per byte).

---
## Memory Regions

|Region|Address Range|Size|
|---|---|---|
|SRAM bit-band region|`0x20000000` – `0x200FFFFF`|1 MB|
|SRAM bit-band alias|`0x22000000` – `0x23FFFFFF`|32 MB|
|Peripheral bit-band region|`0x40000000` – `0x400FFFFF`|1 MB|
|Peripheral bit-band alias|`0x42000000` – `0x43FFFFFF`|32 MB|

> The alias region is just **address space** — it does not store any new data. It is a "remote control" for individual bits in the real region.

---
## The Formula

```
alias_address = alias_base + (byte_offset × 32) + (bit_number × 4)
```

|Term|Meaning|
|---|---|
|`alias_base`|Start of the alias region (`0x22000000` for SRAM)|
|`byte_offset`|How far your variable is from the start of the bit-band region|
|`bit_number`|Which bit (0–31) inside that variable you want to control|
|`× 32`|Each byte expands to 32 bytes in the alias (8 bits × 4 bytes)|
|`× 4`|Each bit gets a 4-byte (32-bit) slot|

### Example

**Goal:** Set bit 3 of address `0x20000000`

```
byte_offset = 0x20000000 - 0x20000000 = 0
bit_number  = 3

alias = 0x22000000 + (0 × 32) + (3 × 4)
      = 0x22000000 + 0 + 12
      = 0x2200000C
```

Writing `1` to `0x2200000C` sets bit 3 of `0x20000000`.

**Before:**

```
bit:   7  6  5  4  3  2  1  0
value: 0  0  0  0  0  0  0  0
```

**After (`*0x2200000C = 1`):**

```
bit:   7  6  5  4  3  2  1  0
value: 0  0  0  0  1  0  0  0   → 0x08
```

---
## Using It in C

```c
/* Generic bit-band macro for SRAM */
#define BITBAND_SRAM(addr, bit) \
    ((volatile uint32_t *)(0x22000000 + \
    (((uint32_t)(addr) - 0x20000000) << 5) + \
    ((bit) << 2)))

/* Generic bit-band macro for Peripherals */
#define BITBAND_PERIPH(addr, bit) \
    ((volatile uint32_t *)(0x42000000 + \
    (((uint32_t)(addr) - 0x40000000) << 5) + \
    ((bit) << 2)))

/* Usage */
uint32_t myVar = 0;

*BITBAND_SRAM(&myVar, 3) = 1;   // Set bit 3
*BITBAND_SRAM(&myVar, 3) = 0;   // Clear bit 3
uint32_t val = *BITBAND_SRAM(&myVar, 3);  // Read bit 3
```

> `<< 5` is the same as `× 32`, and `<< 2` is the same as `× 4` — just written as bit shifts for efficiency.

---
## Key Properties

- **Atomic** — the hardware performs the bit change as a single bus transaction
- **No masking needed** — you address the bit directly, no `|=` or `&=`
- **No interrupts can fire between read and write** — because there is no separate read and write
- **Read works too** — reading the alias word returns 0 or 1 for that bit's current state

---
## Limitations

- Only works in the defined bit-band regions (not arbitrary RAM)
- Only available on Cortex-M0+, M3, M4, M7 — not all ARM cores
- Variables must be placed in the bit-band SRAM region (linker script may need adjustment)
- Modern alternatives like `__LDREX`/`__STREX` (exclusive access) or RTOS critical sections are often preferred for portability

---
## Summary

```
1 MB real region  →  holds actual data (8 million bits)
32 MB alias       →  one 4-byte word per bit (just addresses, no storage)

Write 1 to alias address  →  sets that one bit (atomically)
Write 0 to alias address  →  clears that one bit (atomically)
```

The 32 MB alias is not extra memory — it is extra **addressing space** that the hardware uses as a dedicated control panel for individual bits.

Sources:
https://claude.ai/share/063aa46d-e8ee-468a-ae9a-bf0e3ffa8835

Tags: #concept 