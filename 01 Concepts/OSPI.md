# OSPI (Octal SPI)

Building on the SRAM vs PSRAM notes — OSPI is the *bus interface* that connects an MCU to external PSRAM or Flash chips. It's how ESP32-S3's 8MB PSRAM actually talks to the CPU.

---

## What is SPI, and why did it evolve?

**SPI (Serial Peripheral Interface)** is a synchronous serial protocol. Data goes over a single line, one bit at a time. Simple, but slow for memory access.

The bottleneck: every byte needs 8 clock cycles on a single wire.
Solution: add more data lines and transfer bits in parallel.

This gave rise to a family of "xSPI" variants:

| Interface | Data Lines | Bits/Clock (SDR) | Also Known As |
|---|---|---|---|
| SPI | 1 | 1 bit | Standard SPI |
| Dual SPI | 2 | 2 bits | DSPI |
| QSPI | 4 | 4 bits | Quad SPI |
| **OSPI** | **8** | **8 bits** | **Octal SPI, OctoSPI** |

> **OSPI = 8× data lines** — transfers a full byte every single clock cycle in SDR mode.

---

## OSPI Signals (Pin Breakdown)

A typical OSPI bus has these signals:

```
CLK      — Clock (from MCU)
nCS      — Chip Select, active low
DQ[0:7]  — 8 bidirectional data lines
DQS      — Data Strobe (used in DDR mode for edge alignment)
```

In **SDR mode** (Single Data Rate): 8 bits per clock edge (rising only)
In **DDR mode** (Double Data Rate): 8 bits per edge × 2 edges = **16 bits per clock cycle**

> DQS is optional in SDR but **mandatory** in DDR — it tells the receiver which edge has valid data.

---

## SDR vs DDR — The Speed Multiplier

```
SDR (Single Data Rate):
  Clock: ↑___↑___↑___
  Data:  [D0][D1][D2]   ← sample on rising edge only

DDR (Double Data Rate):
  Clock: ↑___↓___↑___
  Data:  [D0][D1][D2]   ← sample on BOTH edges
```

With OSPI + DDR at 200 MHz clock:
- Effective data rate = 8 bits × 2 × 200 MHz = **3200 Mbps = 400 MB/s**

That's approaching LPDDR territory, on just ~10 pins.

---

## Transaction Structure

Every OSPI memory access follows this sequence:

```
[CMD] → [ADDR] → [DUMMY CYCLES] → [DATA]
```

- **CMD** — opcode sent to the memory (e.g. Read, Write, Read Status)
- **ADDR** — 3 or 4 byte address of the target location
- **DUMMY CYCLES** — wait states so the memory can prepare data (varies by speed/device)
- **DATA** — actual bytes read or written

> In older SPI: CMD sent on 1 line. In OSPI: CMD, ADDR, and DATA can all go over all 8 lines simultaneously (called "8-8-8 mode").

---

## Operating Modes

OSPI supports different configurations for each phase of a transaction:

| Mode | CMD lines | ADDR lines | DATA lines |
|---|---|---|---|
| 1-1-8 | 1 | 1 | 8 |
| 1-8-8 | 1 | 8 | 8 |
| 8-8-8 | 8 | 8 | 8 |

Most OSPI memories default to single-line SPI on power-up and must be configured (via special commands) into full octal/DDR mode.

---

## Memory-Mapped Mode (XIP)

This is the killer feature of OSPI on MCUs.

Normally: CPU → request → OSPI controller → fetch from external memory → return data (lots of overhead).

With **memory-mapped mode**:
- The entire external flash/PSRAM appears as a **normal address range** in the MCU's memory map
- CPU reads it just like internal SRAM — using `memcpy()`, pointer dereference, even executing code (XIP = Execute In Place)
- The OSPI controller handles all the protocol details transparently in hardware

Example on STM32: external OSPI flash mapped at `0x9000 0000`
Example on ESP32-S3: external PSRAM mapped into the data/instruction cache

> This is how embedded devices run GUI apps, play audio, or run ML models from external memory with
> almost no extra software complexity.

---

## OSPI vs QSPI — Quick Comparison

| Property            | [[QSPI]]              | OSPI                         |
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

## Dummy Cycles — Why They Exist

At high clock speeds, the memory chip needs a few extra clock cycles to internally retrieve data
before it can drive the output lines. These are called **dummy cycles** (also: latency cycles).

- Dummy cycles contain no useful data — just padding
- The number required increases with clock frequency
- Must match between MCU controller config and memory chip's datasheet
- Getting this wrong = garbage data (common gotcha during bring-up)

Example from IS25LX256: **5 dummy cycles** needed at 50 MHz clock.

---

## Connection to the PSRAM Notes

[[SRAM & PSRAM]]

From the SRAM vs PSRAM notes: ESP32-S3 has **8MB PSRAM** connected externally.
That external PSRAM chip is connected to the ESP32-S3 via **OSPI (Octal SPI)**.

```
ESP32-S3 SoC
   └── OSPI Controller ─── [8 data lines + CLK + CS + DQS] ──► PSRAM chip (e.g. APS6404)
```

Without OSPI, that PSRAM would only be accessible at QSPI speeds (half the bandwidth).
With OSPI + DDR, the PSRAM can sustain hundreds of MB/s — fast enough for display framebuffers
and ML inference.

---

## Real MCUs with OSPI

| MCU / SoC | OSPI Notes |
|---|---|
| ESP32-S3 | OPI (Octal PSRAM interface) for external PSRAM |
| STM32H7A3/B3 | Dual OctoSPI with I/O manager (can mux two memories) |
| STM32U5 | OctoSPI with memory-mapped XIP support |
| TI AM64x | OSPI + HyperBus controller, supports DDR NOR flash |
| Xilinx Versal | Cadence OSPI IP, used for boot flash |

---

## Common Gotchas

- **Default state is single SPI** — must send special config commands to unlock octal/DDR mode
- **Dummy cycle mismatch** — if wrong, reads return 0xFF or garbage; check the datasheet
- **DQS is needed in DDR** — without it, data eye is unreliable at high speeds
- **Not all OSPI flashes are supported** — always verify the specific part against the MCU's compatibility list
- **Memory-mapped mode is read-biased** — writing in this mode has restrictions on some controllers

---

## Quick Summary

- **OSPI = 8 data lines** instead of SPI's 1 or QSPI's 4
- Supports **DDR** → effectively 16 bits per clock → very high bandwidth on a small pin budget
- **DQS strobe** handles edge alignment in DDR mode
- **Memory-mapped mode** makes external flash/PSRAM transparent to software (feels like internal RAM)
- The go-to interface for connecting **external PSRAM and NOR Flash** to modern MCUs
- Backward compatible with QSPI and SPI devices
