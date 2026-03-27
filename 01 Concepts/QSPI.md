# Quad Serial Peripheral Interface

> Direct evolution of SPI → 4 data lines instead of 2.
> The most common interface for external NOR Flash on modern MCUs.
> Sits between standard SPI and OSPI in the xSPI family.

[[SPI]]

---

## Why QSPI Exists

Standard SPI bottleneck: 1 data line = 1 bit per clock cycle.
To read 1 byte from flash = 8 clock cycles just for data, plus CMD + ADDR overhead.

Before QSPI, the alternatives were:
- **Faster SPI clock** → limited by signal integrity and flash chip specs
- **Parallel NOR Flash** → 8/16/32 address+data pins — fast, but huge pin count, costly PCB routing
- **Accepting the slowness** → not viable for code execution, GUI, audio

QSPI solution: **4 bidirectional data lines** (IO0–IO3) instead of separate MOSI/MISO.
4 bits per clock cycle → **4× the bandwidth** of standard SPI at the same clock speed.

---

## Signals (Pin Breakdown)

A typical QSPI flash package (e.g. W25Q128, 8-pin SOIC):

```
CLK    — Clock (from MCU)
nCS    — Chip Select, active LOW
IO0    — Data line 0  (was MOSI in standard SPI mode)
IO1    — Data line 1  (was MISO in standard SPI mode)
IO2    — Data line 2  (Write Protect WP in standard SPI mode)
IO3    — Data line 3  (Hold/Reset in standard SPI mode)
VCC    — Power
GND    — Ground
```

> IO2 and IO3 double as WP and HOLD in legacy SPI mode.
> In full quad mode, all 4 are data lines — WP and HOLD functions are disabled.

---

## Operating Modes (x-y-z notation)

Each phase of a QSPI transaction can use a different number of lines:

```
[CMD] → [ADDR] → [DUMMY] → [DATA]
```

The notation `1-1-4` means:
- 1 line for CMD
- 1 line for ADDR
- 4 lines for DATA

| Mode | CMD | ADDR | DATA | Notes |
|---|---|---|---|---|
| 1-1-1 | 1 | 1 | 1 | Standard SPI (backward compat) |
| 1-1-2 | 1 | 1 | 2 | Dual output read |
| 1-2-2 | 1 | 2 | 2 | Dual I/O read |
| 1-1-4 | 1 | 1 | 4 | Quad output read (most common) |
| 1-4-4 | 1 | 4 | 4 | Quad I/O read (faster, saves cycles) |
| **4-4-4** | **4** | **4** | **4** | **QPI mode — full quad everything** |

- Most QSPI flash defaults to 1-1-1 on power-up.
- MCU sends a special enable command to switch to 1-1-4 or 1-4-4 for fast reads.
- QPI (4-4-4) mode requires writing a config register — used less often, chip-specific.

![[QSPI single & double bit.png|637]]

---

## Transaction Structure

```
nCS: ‾‾‾╗___________________________╔‾‾‾
CLK:     ╚═╗╔╗╔╗╔╗╔╗╔╗╔╗╔╗╔╗╔╗╔╗╔╝
          [CMD ] [ADDR  ][DUM][DATA ]
          1 line  1 line      4 lines  ← for 1-1-4 mode
```

- **CMD** — opcode (e.g. `0x6B` = Fast Read Quad Output)
- **ADDR** — 3-byte (24-bit) or 4-byte (32-bit) address
- **DUMMY CYCLES** — wait states so the flash can prepare data
- **DATA** — bytes streamed out on all 4 IO lines simultaneously

---

## SDR vs DDR in QSPI

Most QSPI controllers and flash chips support both:

| Mode | Bits per clock | When sampled |
|---|---|---|
| SDR (Single Data Rate) | 4 bits | Rising edge only |
| DDR (Double Data Rate) | 8 bits | Rising AND falling edge |

DDR QSPI effectively doubles bandwidth again:
- 100 MHz clock × 4 lines × 2 edges = **800 Mbps = 100 MB/s**

> Not all flash chips support DDR. Check the datasheet.
> DDR requires careful trace matching on PCB — timing margin is tighter.

---

## Dummy Cycles

Same concept as OSPI — the flash chip needs a few clocks to fetch data internally
before it can drive the output lines.

- Number of dummy cycles = f(clock speed, operating voltage, device)
- Specified in the flash datasheet (e.g. 8 dummy cycles at 104 MHz for W25Q128)
- Must be configured in the MCU's QSPI controller registers
- **Wrong dummy cycles = garbage data** — common bring-up mistake

---

## Operating Modes of the QSPI Controller (MCU side)

QSPI controllers on MCUs typically have 3 modes:

### 1. Indirect Mode
- CPU controls the transaction manually via registers
- Write CMD, ADDR, data to registers → controller sends it → read result back
- Flexible but slower (CPU involved in every transaction)
- Used for: writing flash, erasing sectors, reading status registers

### 2. Status Polling Mode
- Controller repeatedly sends a read-status command until a bit condition is met
- CPU is freed up while waiting
- Used for: waiting for a flash write/erase to complete

### 3. Memory-Mapped Mode (XIP)
- Flash appears as a normal address range in the MCU's memory map
- CPU reads/dereferences pointers directly → controller handles QSPI protocol
- Can execute code from flash without copying to RAM (XIP = Execute In Place)
- Used for: large firmware images, assets, lookup tables, string literals

> XIP is the killer feature. On STM32 it's `0x9000 0000`. On RP2040 it's `0x1000 0000`.

---

## Dual-Flash Mode

Some QSPI controllers support connecting **two flash chips simultaneously**:

```
MCU QSPI controller
    ├── IO0, IO1, IO2, IO3 ──► Flash Chip A
    └── IO4, IO5, IO6, IO7 ──► Flash Chip B  (shares CLK, different CS)
```

Both chips are accessed in parallel:
- Flash A handles even bytes, Flash B handles odd bytes (interleaved)
- Doubles throughput AND doubles capacity
- Used on high-end MCUs (STM32H7, i.MX RT)

---

## QSPI vs Standard SPI

| Property | SPI | QSPI |
|---|---|---|
| Data lines | 2 (MOSI + MISO) | 4 (IO0–IO3) |
| Duplex | Full (simultaneous TX+RX) | Half (data phase is one direction) |
| Bits/clock (data phase) | 1 | 4 |
| Typical bandwidth | ~10–50 Mbps | ~80–200 Mbps |
| Backward compatible | — | Yes (1-1-1 mode = plain SPI) |
| Pin count | ~4 + 1 CS per slave | ~6 + 1 CS per slave |
| XIP support | Rarely | Yes (on MCU controllers) |
| Main use | Sensors, displays, misc peripherals | NOR Flash, large external storage |

---

## OSPI vs QSPI — Quick Comparison

| Property            | QSPI                  | [[OSPI]]                     |
| ------------------- | --------------------- | ---------------------------- |
| Data lines          | 4 (DQ0–DQ3)           | 8 (DQ0–DQ7)                  |
| Max SDR throughput  | 4 bits/cycle          | 8 bits/cycle                 |
| DDR support         | Sometimes             | Yes (common)                 |
| DQS strobe          | Rarely                | Yes (DDR mode)               |
| Pin count           | ~6                    | ~11                          |
| Typical use         | NOR Flash, older MCUs | PSRAM, NOR Flash, newer MCUs |
| Backward compatible | With SPI              | With QSPI and SPI            |

> OSPI is backward compatible — an OSPI controller can drive QSPI or plain SPI devices too.

---
## Real MCUs with QSPI

| MCU | QSPI Notes |
|---|---|
| STM32F4 / F7 / H7 | QuadSPI peripheral, memory-mapped XIP |
| RP2040 (Raspberry Pi Pico) | XIP QSPI flash is mandatory — no internal flash |
| ESP32 (original) | QSPI for both internal flash and optional PSRAM |
| nRF9160 | QSPI for external flash |
| SAM D5x / E5x (Microchip) | QSPI with XIP support |
| PSoC 6 (Infineon) | SMIF block, QSPI + AES-128 encryption for stored data |

---

## Common Gotchas

- **Power-up state is SPI mode** — must send enable command before quad reads work
- **WP and HOLD pins** — must be driven HIGH (or disabled) in quad mode, or the chip won't respond
- **Dummy cycle mismatch** — results in 0xFF or shifted data; check datasheet table carefully
- **QPI mode persistence** — some chips retain QPI mode across power cycles (stored in status register); others reset to SPI mode on power-up
- **4-byte address mode** — flash > 128Mbit needs 32-bit addresses; MCU and flash must both be configured for it
- **XIP and writes don't mix** — can't erase/write flash while executing from it in XIP mode; must switch to indirect mode first

---

## Quick Summary

- QSPI = 4 bidirectional data lines (IO0–IO3) vs SPI's 1+1
- **4× bandwidth** at same clock speed; DDR doubles it again
- Starts in SPI-compatible mode at power-up; needs explicit enable for quad mode
- Transaction phases: CMD → ADDR → DUMMY → DATA (each phase can use 1 or 4 lines)
- MCU controller has 3 modes: indirect, status-polling, memory-mapped (XIP)
- Primary use: **external NOR Flash** on MCUs
- Stepping stone between SPI and OSPI (8 lines) in the xSPI family

Tags: #concept 