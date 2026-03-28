*2026-03-25* 

## Overview

- Flash memory = **non-volatile storage**
- Stores data using **charge trapped in transistors**
- Used in:
    - SSD
    - USB drives
    - Embedded systems (MCU flash)

---
## Core Concept

Flash memory works by storing **electrons inside a floating gate**, which changes transistor behaviour.

- Built using **floating-gate MOSFET**
- Data = **threshold voltage change**

---
## Memory Cell Structure

- **Control Gate (CG)** → input control
- **Floating Gate (FG)** → stores charge
- **Oxide Layer** → insulates electrons

👉 Key idea:
- Electrons trapped = logic state

---
## Operations

Program (Write)
- Apply **high voltage**
- Electrons tunnel into floating gate
- Changes threshold voltage

Erase
- Apply **reverse voltage**
- Electrons removed from floating gate

Read
- Apply small voltage
- Measure current → detect stored charge

---
## Physics

- Based on:
    - **Fowler–Nordheim tunnelling**
    - Charge trapping in insulated gate
- This changes transistor conduction

---
## Memory Organization

Cell → Page → Block → Chip
- **Page** → smallest write unit
- **Block** → smallest erase unit

---
## Key Constraint

- Cannot overwrite directly
- Must:
    1. Read block
    2. Erase block
    3. Rewrite

👉 Leads to:
- Write amplification

---
## Types of Flash

Based on Architecture
- **NAND Flash**
    - High density
    - Used in SSD, USB
- **NOR Flash**
    - Faster random access
    - Used in embedded systems

![[nor vs nand.png]]

Based on Bits per Cell
- SLC → 1 bit
- MLC → 2 bits
- TLC → 3 bits
- QLC → 4 bits

---
## SSD Internal Behaviour

Garbage Collection
- Moves valid data
- Erases unused blocks

Wear Levelling
- Distributes writes evenly
- Prevents early failure

---
## Limitations

- Limited write cycles
- Charge leakage over time
- Needs controller logic:
    - ECC
    - Bad block management

---
## Embedded Perspective

- MCU Flash:
    - Same principle
    - But simpler controller
- EEPROM:
    - Similar but slower, byte-level erase
- RAM:
    - Volatile (no charge trapping)

---
## Interview Insight

- Flash memory = **charge storage + threshold voltage detection**
- “Data is stored as electrons trapped in a floating gate”

---


Sources:
1. https://www.youtube.com/watch?v=r2KaVfSH884

Tags: #concept