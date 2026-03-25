*25/03/2026*

Quick reference for understanding the difference between SRAM and PSRAM, and why some MCUs ship with PSRAM instead of true SRAM.

---

## What is SRAM?

**Static RAM** — stores each bit using a **6-transistor flip-flop** circuit.

- Holds data as long as power is on — *no refresh needed*
- Fast access, low latency
- Low power consumption when idle
- **Downside:** uses a lot of die space → expensive per MB

---

## What is PSRAM?

**Pseudo-SRAM** — *looks* like SRAM from the outside, but is actually **DRAM internally**.

- Each bit stored as: **1 transistor + 1 capacitor** (like DRAM)
- Has a built-in controller that handles DRAM refresh cycles automatically
- From the CPU's perspective, it behaves just like SRAM (no refresh commands needed)
- **Downside:** slightly higher latency, small power overhead from internal refresh

> **Key insight:** The "pseudo" part means the complexity of DRAM refresh is hidden inside the chip itself.

---

## Side-by-Side Comparison

| Property           | SRAM                      | PSRAM                            |
| ------------------ | ------------------------- | -------------------------------- |
| Internal structure | 6-transistor flip-flop    | 1T + 1C DRAM cell                |
| Needs refresh?     | ❌ No                      | ✅ Yes (handled internally)       |
| Access speed       | ⚡ Faster - Up to 960 MB/s | 🐢 Slightly slower - 40-160 MB/s |
| Die size / density | Large (expensive)         | Small (cheap)                    |
| Cost per MB        | Higher                    | Lower                            |
| Power (idle)       | Very low                  | Low (refresh overhead)           |
| Typical use        | CPU cache, on-chip RAM    | Large external RAM buffers       |
> ***Note**: Newer PSRAM variants using **Quad-SPI or Octal-SPI interfaces** (e.g., ESP32-S3) significantly improve speed, reducing the gap with SRAM, but SRAM still maintains a clear performance advantage.*

---

## Why do some MCUs only have PSRAM?

### 1. Cost
Embedding large blocks of true SRAM on-chip = expensive silicon.
PSRAM cells are ~6× denser, so way more RAM per dollar.

### 2. Die Size
More SRAM = physically bigger chip.
For cost-sensitive embedded/IoT devices, keeping the die small matters a lot.

### 3. Usually External Anyway
When an MCU needs *large* RAM (graphics buffers, audio, ML models), it's added as an **external chip** over SPI / QSPI / OPI.
PSRAM chips are cheap and widely available in these form factors.

### 4. Use Case Tolerates the Latency
Many embedded workloads don't need extreme speed:
- Web server data buffering (ESP32)
- Display framebuffers (LVGL)
- File system caching
- TensorFlow Lite model weights

For these, the latency tradeoff is totally acceptable.

---

## Real-World Example: ESP32-S3

The ESP32-S3 advertises **"8MB PSRAM"** — this means:
- A cheap, high-density PSRAM chip is paired externally with the MCU
- Connected over Octal SPI (OPI) interface
- Used for LVGL display buffers, ML models, etc.
- Equivalent true SRAM would cost many times more

[[OSPI]]

---

## Memory Analogy

|            | SRAM                     | PSRAM                                   |
| ---------- | ------------------------ | --------------------------------------- |
| Like...    | Expensive, fast NVMe SSD | Cheap HDD with a smart cache controller |
| You see... | Raw speed                | Similar interface, hidden complexity    |

---

## Quick Summary

- **SRAM** = fast, expensive, uses lots of chip area → used for small on-chip RAM and CPU cache
- **PSRAM** = cheap, dense, DRAM internally with hidden refresh → used for large external RAM on MCUs
- MCUs use PSRAM when they need **lots of RAM cheaply**, and the workload doesn't demand true SRAM speed



#concepts 