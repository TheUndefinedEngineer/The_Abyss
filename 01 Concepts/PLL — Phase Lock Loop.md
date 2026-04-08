*08-04-2026* 
## What is it?

A PLL is a feedback control circuit that locks an output oscillator to a reference input frequency. Its primary use in digital systems is **frequency synthesis** — taking a low-frequency reference and producing a stable, higher-frequency output.

It is a general-purpose building block found across virtually all digital and RF hardware — not specific to any vendor or MCU family.

---
## Core Working

![[block_diagram.png]]

|Signal|Meaning|
|---|---|
|`f_R`|Reference frequency input (HSI/HSE on STM32)|
|`E(t)`|Phase error signal (time domain)|
|`Ev`|Filtered error voltage fed to VCO|
|`f_o`|Output frequency|

When locked: `f_out = f_in`

**VCO -> Voltage Controlled Oscillator** [[VCO - Voltage Controlled Oscillator]]

---
### Lock Range vs Capture Range

#### Capture Range (Pull-in Range)

The range of input frequencies around the **VCO** center frequency onto which the loop can lock when starting from the unlocked condition.
- If `f_R` is too far from `f_o`, the PLL simply cannot lock — it won't even try
- Narrower than lock range
- Also called **acquisition range**
![[capture_range.png]]

#### Lock Range (Hold-in Range)

The range of input frequencies over which the loop remain in the lock condition once it has captured the input signal.
- Wider than capture range
- If `f_R` drifts slowly within this range, the PLL tracks it and stays locked
- Also called **tracking range**
- If the input frequency goes out of the lock range then the VCO runs at the *free running frequency*.
![[lock_range.png]]

```
|-----------------------------------------------|
|              Lock Range                       |
|         |----------------------|              |
|         |    Capture Range     |              |
|         |----------------------|              |
|-----------------------------------------------|
                    ↑
               f_center (VCO free-running freq)
```

Capture range is always **a subset** of lock range.
#### Why both exist
- The **low-pass filter** is what creates the difference between them
- A narrow LPF bandwidth → smaller capture range but better noise rejection
- Once locked, the feedback loop can handle larger deviations because it's already tracking — hence lock range being wider
#### Frequency Synthesizer
![[multiply_frequency_2.png]]
- The 100 kHz needs to convert to 1 MHz so the VCO will output 10 MHz as N is 10, giving 1 MHz but the output is changed to 10 MHz.
![[multiply_frequency_1.png]]
- The input frequency(f) will be divide by N making the output frequency = f/N
![[divide_frequency.png]]

---
## Where PLLs appear?

| Context                | Example usage                                                                                                            |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| MCUs                   | STM32 [[Section 6 - Reset & Clock Control (RCC)]], NXP, TI, Nordic — all have PLL blocks with similar M/N/P style config |
| Application processors | Raspberry Pi 5 uses multiple PLLs for CPU, GPU, peripheral clocks                                                        |
| FPGAs                  | Xilinx/Intel have dedicated PLL/MMCM blocks for clock synthesis                                                          |
| Desktop CPUs           | Multiply 100 MHz base ref up to GHz using internal PLLs                                                                  |
| USB / PCIe / HDMI      | Clock recovery circuits rely on PLLs                                                                                     |
| RF transceivers        | PLLs used as frequency synthesizers                                                                                      |

On higher-level systems (Pi, desktop), the OS/bootloader configures PLLs transparently. On MCUs, they are configured explicitly via registers.

---
## !
Sources:
1. https://www.youtube.com/watch?v=Q5dC9TbzR9k
Tags: #concept #microcontroller 