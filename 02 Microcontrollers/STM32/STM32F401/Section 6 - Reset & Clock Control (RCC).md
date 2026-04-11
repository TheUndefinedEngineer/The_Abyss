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
## !
Sources:

Tags: #concept #microcontroller 

