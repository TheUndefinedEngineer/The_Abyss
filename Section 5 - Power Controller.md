*07-04-2026*
## Overview

The PWR peripheral controls:

- Supply voltage supervision (POR, BOR, PVD)
- Voltage regulator scaling
- Low-power mode entry and exit (Sleep, Stop, Standby)
- Backup domain write protection

Base address: `0x4000 7000` (APB1 bus)

---
## Power Supply Schemes

Two valid VDD configurations:

|Mode|VDD Range|Notes|
|---|---|---|
|Internal regulator enabled|1.8 V – 3.6 V|Normal operation|
|Internal regulator disabled|1.7 V – 3.6 V|Requires external supervisor on PDR_ON pin|

> [!important] VBAT The RTC and backup registers can be powered from **VBAT** (1.65–3.6 V) when VDD is off. If no battery is used, connect VBAT to VDD with a 100 nF decoupling cap.

### Independent ADC Supply

- ADC has its own supply pin: **VDDA**
- Isolated ground: **VSSA**
- Optional external reference: **VREF+** (range: 1.7 V to VDDA)

---
## Power Supply Supervisors

### POR/PDR — Power-On / Power-Down Reset

- Built-in circuit keeps device in reset until VDD/VDDA rises above **VPOR/PDR** threshold
- ~40 mV hysteresis
- Active down to **1.8 V**; below 1.8 V, disable via PDR_ON pin

### BOR — Brownout Reset

- Keeps device in reset until VDD exceeds programmed **VBOR** threshold
- Configured via **Option Bytes** (`BOR_LEV[1:0]` in FLASH_OPTCR)
- **Default: BOR OFF** (POR/PDR threshold applies instead)
- ~100 mV hysteresis

|BOR_LEV|Threshold|
|---|---|
|00|VBOR3 (highest)|
|01|VBOR2|
|10|VBOR1|
|11|BOR OFF|

### PVD — Programmable Voltage Detector

- Monitors VDD against a software-selected threshold
- Enabled by setting **PVDE** in `PWR_CR`
- Threshold selected by **PLS[2:0]** in `PWR_CR` (2.2 V – 2.9 V in 0.1 V steps)
- Output flag: **PVDO** in `PWR_CSR`
- Internally connected to **EXTI line 16** → can generate interrupt on rising/falling edge

> [!tip] Use Case Connect PVD interrupt to an emergency shutdown routine when supply voltage drops.

---
## Voltage Regulator

The embedded linear regulator supplies the 1.2 V digital core domain.

- Output: ~1.2 V
- Requires external capacitors on **VCAP_1** (and VCAP_2 on some packages)
- Scaling controlled by **VOS[1:0]** in `PWR_CR`

|VOS[1:0]|Scale|Max HCLK|
|---|---|---|
|01|Scale 3|60 MHz|
|10|Scale 2|84 MHz|

> [!warning] VOS Timing Rule VOS can only be changed **when PLL is OFF**. The new scale takes effect only after PLL is re-enabled. When PLL is OFF, hardware forces Scale 3 regardless of VOS setting.

### Regulator Behavior per Power Mode

|Mode|Regulator State|
|---|---|
|Run|Full power, scale 2 or 3|
|Stop|Main (MR) or Low-Power (LPR) mode, selected by LPDS bit|
|Standby|Powered OFF — SRAM and register contents lost|

---
## Low-Power Modes

Three low-power modes are available:

|Mode|CPU|Clocks|Regulator|SRAM/Regs|Wake-up|
|---|---|---|---|---|---|
|**Sleep**|Stopped|Peripherals running|ON|Retained|Any NVIC interrupt|
|**Stop**|Stopped|All 1.2V clocks OFF, HSI/HSE OFF|MR or LPR|Retained|EXTI lines|
|**Standby**|Stopped|All clocks OFF|OFF|**Lost**|WKUP pin, RTC, NRST, IWDG|

Entry is via `WFI` / `WFE` instructions (or return from ISR with SLEEPONEXIT=1).

### Sleep Mode

- Only the CPU core stops; peripherals keep running
- **Entry:** `WFI` or `WFE` with `SLEEPDEEP = 0` in SCB System Control Register
- **Exit:** Any interrupt (WFI) or event (WFE)
- Zero wake-up latency

### Stop Mode

- All 1.2 V domain clocks halted; PLLs, HSI, HSE disabled
- SRAM and register contents **preserved**
- **Entry:** `WFI`/`WFE` with `SLEEPDEEP = 1` and `PDDS = 0` in `PWR_CR`
- **Exit:** Any configured EXTI line
- On exit: **HSI is selected as system clock** (must reconfigure PLL manually)

> [!warning] Stop Mode Entry Condition All EXTI pending bits, peripheral interrupt pending bits, and RTC flags **must be cleared** before executing WFI/WFE, otherwise Stop mode entry is silently ignored.

Optional Stop sub-modes (configured via `LPDS`, `FPDS`, `MRLVDS`, `LPLVDS` bits in `PWR_CR`):

|Sub-mode|Description|Wake-up Latency|
|---|---|---|
|STOP MR|Main regulator ON|HSI startup only|
|STOP LP|Low-power regulator|HSI + regulator startup|
|STOP MRFPD|Main regulator + Flash power-down|HSI + Flash wake-up|
|STOP LPFPD|Low-power regulator + Flash power-down|HSI + Flash + regulator|

### Standby Mode

- Voltage regulator powered OFF → 1.2 V domain lost
- Only backup domain (RTC, backup registers) and Standby circuitry survive
- **Entry:** `SLEEPDEEP = 1` and `PDDS = 1` in `PWR_CR`
- **Exit:** WKUP pin rising edge, RTC alarm/wake-up/tamper/timestamp, NRST, IWDG reset
- On exit: full reset sequence (boot pins sampled, option bytes loaded, reset vector fetched)

> [!note] I/O State in Standby All I/O pins go **high-impedance** except: NRST, RTC_AF1 (PC13 if configured), WKUP (PA0 if enabled via EWUP bit).

---
## RTC Wake-up from Stop / Standby

### Wake from Stop via RTC Alarm

1. Configure **EXTI Line 17** for rising edge
2. Enable RTC Alarm interrupt in `RTC_CR` (`ALRAIE` or `ALRBIE`)
3. Configure the RTC alarm value

### Wake from Stop via RTC Wake-up Timer

1. Configure **EXTI Line 22** for rising edge
2. Enable RTC wake-up interrupt in `RTC_CR` (`WUTIE`)
3. Configure the RTC wake-up period

### Wake from Stop via RTC Tamper / Timestamp

1. Configure **EXTI Line 21** for rising edge
2. Enable interrupt in `RTC_CR` or `RTC_TAFCR`

> [!important] Safe Flag Clearing Sequence (before re-entering low-power mode)
> 
> 1. Disable the RTC interrupt (ALRAIE / WUTIE / TAMPIE / TSIE)
> 2. Clear the RTC event flag (ALRAF / WUTF / TAMP1F / TSF)
> 3. Clear PWR WUF flag → write `CWUF = 1` in `PWR_CR`
> 4. Re-enable the RTC interrupt
> 5. Re-enter low-power mode
> 
> **Why:** If the RTC flag is still set when you re-enter, the rising edge detection won't fire on the next event.

---
## PWR Registers

### PWR_CR — Power Control Register

**Address:** `0x4000 7000` | **Reset:** `0x0000 8000`

|Bits|Field|Access|Description|
|---|---|---|---|
|15:14|VOS[1:0]|rw|Voltage scaling (01=Scale3/60MHz, 10=Scale2/84MHz)|
|13|ADCDC1|rw|ADC improvement bit (see AN4073, 2.7–3.6 V only)|
|11|MRLVDS|rw|Main regulator low-voltage + Flash deep sleep in Stop|
|10|LPLVDS|rw|LP regulator low-voltage + Flash deep sleep in Stop|
|9|FPDS|rw|Flash power-down in Stop mode|
|8|DBP|rw|Disable backup domain write protection|
|7:5|PLS[2:0]|rw|PVD threshold (000=2.2V … 111=2.9V)|
|4|PVDE|rw|PVD enable|
|3|CSBF|w|Clear Standby flag (write 1)|
|2|CWUF|w|Clear wake-up flag (write 1, clears after 2 SYSCLK cycles)|
|1|PDDS|rw|0=Stop mode, 1=Standby mode on deepsleep|
|0|LPDS|rw|0=Main regulator in Stop, 1=Low-power regulator in Stop|

### PWR_CSR — Power Control/Status Register

**Address:** `0x4000 7004` | **Reset:** `0x0000 0000`

|Bits|Field|Access|Description|
|---|---|---|---|
|14|VOSRDY|r|1 = voltage scaling output ready|
|9|BRE|rw|Backup regulator enable (maintains backup domain in Standby/VBAT)|
|8|EWUP|rw|Enable WKUP pin (PA0) as wake-up from Standby|
|3|BRR|r|Backup regulator ready|
|2|PVDO|r|PVD output — 1 if VDD below threshold|
|1|SBF|r|Standby flag — set by HW, cleared by CSBF or POR/PDR|
|0|WUF|r|Wake-up event flag|

> [!warning] DBP Synchronization After writing `DBP = 1` in PWR_CR, insert a dummy read of PWR_CR before accessing backup domain registers. The APB1 prescaler introduces a synchronization delay.

---
## Common Code Patterns

### Enter Stop Mode (Low-Power Regulator)

```c
/* 1. Clear pending wake-up flag */
PWR->CR |= PWR_CR_CWUF;

/* 2. Select Stop mode (PDDS=0) with low-power regulator (LPDS=1) */
PWR->CR &= ~PWR_CR_PDDS;
PWR->CR |=  PWR_CR_LPDS;

/* 3. Set SLEEPDEEP in Cortex-M4 SCB */
SCB->SCR |= SCB_SCR_SLEEPDEEP_Msk;

/* 4. Enter Stop — execution halts here until wake-up */
__WFI();

/* 5. Clear SLEEPDEEP on return */
SCB->SCR &= ~SCB_SCR_SLEEPDEEP_Msk;

/* 6. HSI is now SYSCLK — reconfigure PLL if needed */
SystemClock_Config();
```

### Enter Standby Mode

```c
/* 1. Enable WKUP pin if needed */
PWR->CSR |= PWR_CSR_EWUP;

/* 2. Clear standby and wake-up flags */
PWR->CR |= PWR_CR_CSBF | PWR_CR_CWUF;

/* 3. Select Standby mode */
PWR->CR |= PWR_CR_PDDS;

/* 4. Set SLEEPDEEP */
SCB->SCR |= SCB_SCR_SLEEPDEEP_Msk;

/* 5. Enter Standby */
__WFI();
/* Execution never returns here — reset on wake-up */
```

### Enable PVD Interrupt at 2.7 V

```c
/* Enable PWR clock */
RCC->APB1ENR |= RCC_APB1ENR_PWREN;

/* Select 2.7 V threshold (PLS = 101) and enable PVD */
PWR->CR |= (0x5U << PWR_CR_PLS_Pos) | PWR_CR_PVDE;

/* Configure EXTI line 16 for rising and falling edges */
EXTI->RTSR |= EXTI_RTSR_TR16;
EXTI->FTSR |= EXTI_FTSR_TR16;
EXTI->IMR  |= EXTI_IMR_MR16;

/* Enable NVIC */
NVIC_EnableIRQ(PVD_IRQn);
```

### Enable Backup Domain Access

```c
/* Enable PWR clock on APB1 */
RCC->APB1ENR |= RCC_APB1ENR_PWREN;

/* Disable backup domain write protection */
PWR->CR |= PWR_CR_DBP;

/* Dummy read for APB1 sync delay */
(void)PWR->CR;

/* Backup domain is now writable (RTC, RCC_BDCR, BKPxR) */
```

---
## Gotchas & Practical Notes

> [!warning] Stop Mode Clock Recovery After waking from Stop, **HSI is always the system clock**, regardless of what was running before. If you were on PLL/HSE at 84 MHz, you must reconfigure clocks explicitly in your wake-up path. Failure to do so means running at 16 MHz HSI silently.

> [!warning] EXTI Flags Must Be Clear Before Stop Entry If any EXTI pending bit, peripheral interrupt pending bit, or RTC flag is set, Stop mode entry is **silently ignored** — the CPU just continues executing. Always clear all relevant flags before `__WFI()`.

> [!note] Flash Power-Down Trade-off Setting `FPDS = 1` reduces Stop mode current further, but adds a Flash wake-up delay on resume. Avoid if fast wake-up latency matters more than power savings.

> [!note] Backup Regulator (BRE) If you need RTC and backup registers to persist through Standby and VBAT modes, set `BRE = 1` in `PWR_CSR` and wait for `BRR = 1` before proceeding. The DBP bit must be set first.

---
## !
Sources:
1. RM0368 Rev 6, Section 5 (pp. 71–90) 
Tags: #microcontroller #reference 