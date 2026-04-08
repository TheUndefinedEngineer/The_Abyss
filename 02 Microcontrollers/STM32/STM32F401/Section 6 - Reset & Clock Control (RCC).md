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





---
## !
Sources:

Tags: #concept #microcontroller 

