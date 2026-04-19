*07-04-2026* 

## 6.1 Reset
There are 3 types of reset, defined as:
- System Reset
- Power Reset
- Backup Domain Reset

### 6.1.1 System Reset
- Resets all registers' values unless specified otherwise.
- It can be generated when:
	- A low level on the NRST pin (external reset)
	- Window watchdog end of count condition (WWDG reset)
	- Independent watchdog end of count condition (IWDG reset)
	- A software reset (SW reset)
	- Low-power management reset
#### Software reset
The reset source can be identified by checking the reset flags in RCC clock control & status register (*RCC_CSR*).

The SYSRESETREQ bit in Cortex®-M4 with FPU Application Interrupt and Reset Control Register must be set to force a software reset on the device. 

#### Low-power management reset
There are 2 types:
1. Reset generated when entering Standby mode:
	- Enabled by resetting the nRST_STDBY bit in user option bytes.
	- Whenever Standby mode entry sequence is successful, the device will reset instead of entering Standby mode.
2. Reset when entering the Stop mode:
	- Enabled by resetting the nRST_STOP bit in user option bytes.
	- Whenever Stop mode entry sequence is successful, the device will reset instead of entering Stop mode.

### 6.1.2 Power Reset
- Generated when:
	- Power-on (POR reset)
	- Power-down (PDR reset)
	- Brownout (BOR reset)
	- Exiting Standby mode
- It resets all registers' values except the backup domain.
- These sources act on the *NRST(Negative Reset)* pin, always kept low during the delay phase.
- The RESET service routine vector is fixed at address 0x0000_0004 in the memory map.
> [!note]
> The system reset signal provided to the device is output on the NRST pin. The pulse generator guarantees a minimum reset pulse duration of 20 µs for each internal reset source. In case of an external reset, the reset pulse is generated while the NRST pin is asserted low.

### 6.1.3 Backup Domain Reset
- Resets:
	- All RTC registers
	- RCC_BDCR(Backup Domain Control Register) register
	- bit BRE of PWR_CSR register
- Generated when:
	- Software reset, triggered by setting the BDRST bit in RCC_BDCR.
	- VDD power on.
	- VBAT power on.
	  
> [!Note]
> The bit DBP of the register PWR_CR must be set to 1 in order to generate the backup domain reset.

---
*08/04/2026*
## 6.2 Clocks
There are 3 different *primary* clocks which can be used to drive the system (SYSCLK):
- HSI oscillator clk
- HSE oscillator clk
- Main PLL(PLL) clk - [[PLL — Phase Lock Loop]]
There are 2 different *secondary* clocks which can be used to drive low speed peripherals:
- 32 kHz low-speed internal RC (LSI RC)
- 32.768 kHz low-speed external crystal (LSE crystal)
> [!important] Key Insight
> Each clock source can be switched on or off independently when it is not used, to optimize power consumption.

**LSI RC:** Drives the independent watchdog and optionally the RTC used for Auto-wakeup from Stop/Standby mode.

**LSE Crystal:** Optionally drives the RTC clk (RTCCLK).

*11/04/2026*

These clocks provide flexibility to the application in choice of the external crystal or the oscillator to run the core and the peripherals.

Several **prescalers** are available which can be used to configure the bus frequencies:

| BUS  | MAXIMUM FREQUENCY |
| ---- | ----------------- |
| AHB  | 84 MHz            |
| APB1 | 48 MHz            |
| APB2 | 84 MHz            |
All the peripheral clocks are derived from **SYSCLK** except for:
- USB OTG FS clk
- SDIO clk
- I2S clk
USB and SDIO use **PLL48CLK** and I2S uses **PLLI2S** or external clk mapped to **I2S_CKIN** to achieve high-quality audio performance.

The RCC feeds the external clock of the Cortex System Timer (SysTick) with the AHB clock (HCLK) divided by 8. The SysTick can work either with this clock or with the Cortex clock (HCLK), configurable in the SysTick control and status register.

The timer clk freq. are automatically set by hardware.
- If APB prescaler is 1, the timer clk freq. is set to the same freq. as the APB domain.
- If not, they are set to x2 the freq. of the APB domain.

By changing the value of TIMPRE bit in RCC_DCKCDGR register we can change the behaviour of PCLKx which is basically the timer clk freq.
- If the bit is set to 0 : If APB prescaler is set to divide by 1, the timer clk freq.(TIMxCLK) is set to HCLK. Otherwise, TIMxCLK = 2xPCLKx.
- If the bit is set to 1 : If APB prescaler is set to divide by 1 or 2, TIMxCLK = HCLK. Otherwise TIMxCLK = 4xPCLKx.

**TIMxCLK vs PCLKx:**
- **PCLKx** = the APB bus clock after the APB prescaler. What peripherals on that bus actually run at.
- **TIMxCLK** = what the timer's internal counter actually uses. Can be **different** from PCLKx due to the ×2 rule.
- **HCLK** = AHB clock, before APB prescaler. Always ≥ PCLKx.

So the chain is:
```
SYSCLK → [AHB prescaler] → HCLK → [APB prescaler] → PCLKx → [×1 or ×2] → TIMxCLK
```

FCLK acts as Cortex®-M4 with FPU free-running clock.

---
### 6.2.1 HSE Clock
The high speed external clock signal can be generated using:
- HSE external crystal/ceramic resonator
- HSE external user clock

![[HSE-LSE clock sources.png]]

> [!important]
> The resonator and load capacitors have to be placed as close as possible to the oscillator pins (OSC) to minimize output distortion and startup stabilization time.

#### External Source (HSE bypass)
- An external clk source must be provided
- This mode is selected using the **HSEBYP** and **HSEON** bits in the RCC_CR.
- The external clk signal with ~50% duty cycle has to drive the OSC_IN pin.
- The OSC_OUT pin should be left HI-Z.

> [!Question]  What is HI-Z?
> - **Hi-Z (High Impedance)**
> - If a normal output pin is a switch — it's either actively driving **high** (connected to VDD) or actively driving **low** (connected to GND).
> - Hi-Z is a **third state** — the pin is **disconnected from both**. It's just floating, not driving anything.
> 
> **In hardware terms:**
> A GPIO output uses a push-pull driver — a P-MOS on top (pulls high) and N-MOS on bottom (pulls low).
> Hi-Z = **both transistors off**. Nothing is driving the pin. The pin voltage is now determined entirely by whatever is externally connected to it — a pull-up, pull-down, or another device on the bus.

#### External Crystal/Ceramic Resonator(HSE crystal)
- Produces a very accurate rate on the main clk.
- The **HSERDY** flag in RCC_CR indicates if its stable or not.
	- At startup the clk is not released until the bit is set by hardware.
	- An interrupt can be generated if enabled in RCC_CIR.
- It can be switched on and off using the **HSEON** bit in the RCC_CR.
---
*12/04/2026*
### 6.2.2 HSI Clock
Its generated from an internal **16 MHz** RC oscillator and can be used directly as a system clock or PLL input.
- Provides low cost clock source.
- Faster startup than external crystal oscillator/ceramic resonator.
- HSI - High Speed Internal
#### Calibration
- Factory calibrated by ST for 1% accuracy at T<sub>A</sub> = 25$\degree$C.
- After reset, the factory calibration is loaded in the **HSICAL[7:0]** bits in the RCC_CR.
- Voltage and temperature variations affect the RC oscillator speed.
- HSI freq. can be trimmed in the application using the **HSITRIM[4:0]** bits in the RCC_CR.
- The **HSIRDY** flag in RCC_CR indicates if the HSI RC is stable or not.
- At startup, the HSI RC output clock is not released until **HSIRDY** bit is set by hardware.
- HSI RC can be switched on and off using the **HSION** bit in the RCC_CR.
- The HSI signal can also be used as a backup source (Auxiliary clock) if the HSE crystal oscillator fails.
---
### 6.2.3 PLL Configuration
There are 2 PLLs featured in STM32F401xx:
- A main PLL clk by HSE or HSI and features 2 different output clocks.
	- The first output generates the high speed system clock up to 84 MHz.
	- The second output generates the clk for USB OTF FS 48MHz, the random analog generator and SDIO <= 48 MHz.
- A dedicated PLL (PLLI2S) for accurate clk for high-quality audio performance on the I2S interface.

Main-PLL parameters can't be configured once PLL is enabled. It is recommended to configure it before enabling it bu selecting HSI or HSE as the PLL clk source and configure the division factors **'M','P','Q'** and multiplication factor **'N'**.

The PLLI2S uses the same input clk as the main PLL and **PLLM[5:0]** and **PLLSRC** bits are common to both. But PLLI2S has dedicated enable/disable and division factor configuration bits. Similar to main PLL can't be configured after enabling it.

The 2 PLLs are disabled by hardware when entering Stop and Standby modes or when a HSE failure occurs when HSE or PLL are used by system clk. 

RCC_PLLCFGR and RCC_CFGR are used to configure PLL and PLLI2S.

---
### 6.2.4 LSE Clock
It is generated using a 32.768 kHz low speed external crystal or ceramic resonator. 
- It has the advantage to provide a low-power but highly accurate clk source to the real-time clk peripheral (RTC) for clk/calendar or any other timing functions. 
- The LSE oscillator is switched on and off using the **LESON** bit int eh RCC_BDCR.
- The **LSERDY** flag in the RCC_BDCR is used to indicate if the LSE crystal is stable or not.
- At startup, the LSE crystal output clk signal is not released until the **LSERDY** bit is set by the hardware.
- An interrupt can be generated if enabled in the RCC_CIR.
#### External Source (LSE bypass)
- An external clk source must be provided.
- It must have freq. up to 1 MHz.
- This mode is selected by setting the **LSEBYP** and **LSEONE** bits in the RCC_BDCR.
- The external clk signal with ~50% duty cycle to drive the OSC32_IN pin while OSC32_OUT pin should be left HI-Z.
---
*18/04/2026*
### 6.2.5 LSI Clock
It acts as a low powered clock source that can be kept running in Stop and Standby mode for:
- Independent watchdog (IWDG)
- Auto-wakeup unit (AWU)
The clock freq. is around 32kHz.
- It can be turned on and off using the **LSION** bit in the RCC_CSR.
- The **LSIRDY** flag in RCC_CSR indicates if the low-speed internal oscillator is stable or not.
- At startup the clk is not released until **LSION** bit is set by hardware.
- An interrupt can also be generated if enabled in the RCC_CIR.
---
### 6.2.6 System Clock (SYSCLK) selection
- After a system reset, the HSI oscillator is selected as the system clock.
- When a clock source is used directly or through PLL as the system clock, it is not possible to stop it.
- A switch from one clock source to another occurs only if the target clock source is ready.
- If a clock source that is not yet ready is selected, the switch occurs when the clock source is ready.
- Status bits in the RCC_CR indicate which clock(s) is (are) ready and which clock is currently used as the system clock.
---
### 6.2.7 Clock Security System (CSS)
It can be activated by software. The clock detector is enabled after the HSE oscillator startup delay, and disabled when the oscillator stops.

If a failure is detected on the HSE clock, this oscillator is automatically disabled, a clock failure event is sent to the break inputs of advanced-control timer TIM1, and an interrupt is
generated to inform the software about the failure (clock security system interrupt CSSI), allowing the MCU to perform rescue operations. The CSSI is linked to the Cortex®-M4 with
FPU NMI (non-maskable interrupt) exception vector.

> [!note]
> When the CSS is enabled, if the HSE clock happens to fail, the CSS generates an interrupt, which causes the automatic generation of an NMI. The NMI is executed indefinitely unless the CSS interrupt pending bit is cleared. As a consequence, the application has to clear the CSS interrupt in the NMI ISR by setting the CSSC bit in the RCC_CIR.

If the HSE oscillator is used directly or indirectly as the system clock (indirectly meaning that it is directly used as PLL input clock, and that PLL clock is the system clock) and a failure is detected, then the system clock switches to the HSI oscillator and the HSE oscillator is disabled.

If the HSE oscillator clock was the clock source of PLL used as the system clock when the failure occurred, PLL is also disabled. In this case, if the PLLI2S was enabled, it is also disabled when the HSE fails.

---
### 6.2.8 RTC/AWU Clock
Once RTCCLK clk source is selected, the only way to modify the selection is to reset the power domain.

The RTCCLK clk source can be either:
- HSE 1MHz (divided by a programmable prescaler)
- LSE
- LSI
It is selected by programming the **RTCSEL[1:0]** bits in RCC_BDCR and the **RTCPRE[4:0]** bits in RCC_CFGR (clock configuration register).

If LSE is selected as the clk source:
- The RTC will work normally if he backup or the system supply disappears.
If LSI is selected as the AWU clk:
- The AWU state is not guaranteed if the system supply disappears.
> [!question] What is AWU?
> Auto-wakeup unit, a low-power feature in STM microcontrollers that acts like an internal alarm clock, allowing the CPU to wake up from **Active Halt** mode after a predefined time interval without external interrupts.

If HSE oscillator divided by a value between 2 and 31 is used as the RTC clk:
- The RTC state is not guaranteed if the backup or the system supply disappears.

The LSE clock is in the Backup domain, whereas the HSE and LSI clocks are not. As a consequence:

If LSE is selected as the RTC clock:
- The RTC continues to work even if the VDD supply is switched off, provided the VBAT supply is maintained.
If LSI is selected as the Auto-wakeup unit (AWU) clock:
- The AWU state is not guaranteed if the VDD supply is powered off.
If the HSE clock is used as the RTC clock:
- The RTC state is not guaranteed if the VDD supply is powered off or if the internal voltage regulator is powered off (removing power from the 1.2 V domain).

> [!note]
> To read the RTC calendar register when the APB1 clock frequency is less than seven times the RTC clock frequency (f<sub>APB1</sub> < 7xf<sub>RTCLCK</sub>), the software must read the calendar time and date registers twice. The data are correct if the second read access to RTC_TR gives the same result than the first one. Otherwise a third read access must be performed.

> [!important] Good to know!
> RTC calendar registers `RTC_TR` for time, `RTC_DR` for date.

---
### 6.2.9 Watchdog Clock
If the independent watchdog (IWDG) is started by either hardware option or software access, the LSI oscillator is forced ON and cannot be disabled. After the LSI oscillator temporization, the clock is provided to the IWDG.

---
### 6.2.10 Clock-out Capability
Two microcontroller clock output (MCO) pins are available:
- MCO1
	You can output four different clock sources onto the MCO1 pin **(PA8)** using the configurable prescaler (from 1 to 5):
	- HSI clock
	- LSE clock
	- HSE clock
	- PLL clock
	The desired clock source is selected using the **MCO1PRE[2:0]** and **MCO1[1:0]** bits in the RCC_CFGR.
- MCO 2
	You can output four different clock sources onto the MCO2 pin (PC9) using the configurable prescaler (from 1 to 5):
	- HSE clock
	- PLL clock
	- System clock (SYSCLK)
	- PLLI2S clock
	The desired clock source is selected using the **MCO2PRE[2:0]** and **MCO2** bits in the RCC_CFGR.
> [!important] The selected clock to output onto MCO must not exceed 100 MHz (the maximum I/O speed).

---
*19/04/2026*
### 6.2.11 Internal/External Clock measurement using TIM5/TIM11

Capture of  all on-board clock source generators is possible indirectly using **input capture** of TIM5 channel4 and TIM11 channel1.

### TIM5 Channel4
It has an input multiplexer which allows choosing whether the input capture is triggered by the I/O or by an internal clock.
- Selected through **TI4_RMP[1:0]** bits in the **TIM5_OR** register.

The primary purpose of having the LSE connected to the channel4 input capture is to be able to precisely measure the HSI.
- The number of HSI clock counts between consecutive edges of the LSE signal gives the measurement of the internal clock period.
- The high-resolution of LSE helps to determine the internal clock freq. and trim the source to compensate for manufacturing-process and/or temperature and  voltage related freq. deviations.
	- For this purpose HSI has dedicated, user-accessible calibration bits.

Its also possible to measure the LSI freq.
- It is useful for applications that don't have a crystal.
-  The ultralow-power LSI oscillator has a large manufacturing process deviation: by measuring it versus the HSI clock source, it is possible to determine its frequency with the precision of the HSI.
- The measured value can be used to have more accurate RTC time base timeouts (when LSI is used as the RTC clock source) and/or an IWDG timeout with an acceptable accuracy.

Use the following procedure to measure the LSI frequency:
1. Enable the TIM5 timer and configure channel4 in Input capture mode.
2. Set the TI4_RMP bits in the TIM5_OR register to 0x01 to connect the LSI clock internally to TIM5 channel4 input capture for calibration purposes.
3. Measure the LSI clock frequency using the TIM5 capture/compare 4 event or interrupt.
4. Use the measured LSI frequency to update the prescaler of the RTC depending on the desired time base and/or to compute the IWDG timeout.
![[TIM5 input capture.png]]

---
### TIM11 Channel1
It has an input multiplexer which allows choosing whether the input capture is triggered by the I/O or by an internal clock.
- Selected through **TI1_RMP[1:0]** bits in the **TIM11_OR** register.

The HSE_RTC is connected to channel 1 input capture to have rough indication of the external crystal freq.
- It requires that the HSI system clk source.
	- It is useful for instance to ensure compliance with the  IEC 60730/IEC 61335 standards which require to be able to determine harmonic or subharmonic frequencies (–50/+100% deviations).
![[TIM11 input capture.png]]

---



---
## !
Sources:
1. RM0368 reference manual - rev6

Tags: #concept #microcontroller 

