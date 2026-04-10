*10-04-2026* 
## Introduction

A **Schmitt Trigger** is a comparator circuit with **hysteresis** used to eliminate noise from input signals. It uses **two distinct threshold voltages**:
- **Upper Threshold Voltage (V<sub>UT</sub>)**
- **Lower Threshold Voltage (V<sub>LT</sub>)**

This makes the output more stable compared to a simple comparator.

---
## What is a Schmitt Trigger?

A Schmitt Trigger is a **positive feedback comparator circuit** that converts a noisy analog input into a clean digital output.
### Key Idea
- Instead of switching at one voltage level, it switches at **two different levels**
- This prevents rapid toggling due to noise

---
## Working Principle
- When input increases:
    - Output switches only after reaching **V<sub>UT</sub>**
- When input decreases:
    - Output switches only after falling below **V<sub>LT</sub>**
![[schmitt voltage graph.png]]
### Result:
- A **hysteresis loop** is formed
- Noise between V<sub>LT</sub> and V<sub>UT</sub> does **not affect output**
---
## Hysteresis
Hysteresis is the **difference between upper and lower threshold voltages**:
$$
\large
Hysteresis = V_{UT} - V_{LT}
$$
Why it matters?
- Rejects noise
- Stabilizes switching behaviour

---
## Types of Schmitt Trigger

### 1. Inverting Schmitt Trigger
- Output is **inverted**
- Uses **positive feedback**
- Commonly implemented with op-amps
![[inverted_schitt.png|460]]
### 2. Non-Inverting Schmitt Trigger
- Output is **same polarity as input**
- Also uses positive feedback
![[non-inverting schmitt.png|451]]
---
## Transfer Characteristics
- Output switches sharply between HIGH and LOW
- Shows a **loop (hysteresis curve)** instead of a straight line

### Behaviour:
- Rising input → switches at V<sub>UT</sub>
- Falling input → switches at V<sub>LT</sub>

---
## Applications
- Noise removal in digital signals
- Signal conditioning
- Wave shaping
- Switch debouncing
- Relaxation oscillators

---
## Advantages
- High noise immunity
- Clean digital output
- Stable switching
- Prevents false triggering

---
## Disadvantages
- More complex than simple comparator
- Requires careful threshold design

---
## !
Sources:
1. https://www.geeksforgeeks.org/electronics-engineering/schmitt-trigger/

Tags: #concept 