## Active Projects
- [[Bike Black Box]] #project
	- [[Black Box Pinout]] #reference 
- [[Self Balancing Robot]] #project
- [[Medical Infusion Pump]] #project 
	- [[Infusion pump - flow]]
	- [[Infusion Pump Pinout]]

---
## STM32
- [[STM32 NixOS Workflow]] #guide #microcontroller 
- [[STM32 Project Templates]] #reference #microcontroller 
- [[STM32CubeMX USART]] #reference #microcontroller 
- [[Interfacing SD Card With STM32]] #guide #microcontroller 
- [[STM32-Build]] #guide #microcontroller #linux 
- [[STM32-Develop - NixOS]] #guide #microcontroller #linux 

---
## Concepts
### Micro-controller 
- [[Flash Memory]] #concept
- [[SRAM & PSRAM]] #concept
- [[Endianness]] #concept
- [[Bit Banding]] #concept
- [[Section - 2 Memory and Bus Architecture]] #concept #microcontroller 
  - I-Bus, D-Bus, S-Bus
  - DMA Memory Bus, DMA Peripheral Bus
  - BusMatrix, AHB/APB Bridges
  - Memory Organization, Boot Configuration
  - STM32F401 Physical Remap
- [[Section 3 - Embedded flash memory interface]] #concept #microcontroller 
	- Introduction, Features
	- Embedded Flash Memory
- [[Section 5 - Power Controller]] #reference #microcontroller 
	- 
- [[Section 6 - Reset & Clock Control (RCC)]] #concept #microcontroller 
	- Types of reset - system, backup domain, power
	- Clocks
- [[PLL — Phase Lock Loop]] #concept #microcontroller 
- [[VCO - Voltage Controlled Oscillator]] #concept #microcontroller 
### Communication Protocols
- [[Topologies Of Communication]] #concept
- [[UART]] #concept
- [[CAN]] #concept
- [[SPI]] #concept
- [[OSPI]] #concept
- [[QSPI]] #concept
### General
- [[Variables]] #concept
- [[Motor Drivers]] #concept
- [[Unions in C]] #concept 
- [[GPS]] #concept 

---
## Sensors
- [[NEO-6M]] #concept
- [[MPU6050]] #concept #reference

---
## Development Tools
- [[Git]] #guide
- [[SSH - Secure Shell]] #guide
- [[Makefile — Multi-Source Build Guide]] #guide #linux #microcontroller #reference 

---
## Operating Systems
### Linux / Debian
- [[Flatpak Installation - Debian]] #guide #linux
- [[VMWare Installation - Debian]] #guide #linux
- [[UTF-8-locale-General]] #guide #linux
- [[UTF-8-locale-Linux]] #guide #linux
- [[Formatting SD Card]] #guide #linux 

### NixOS
- [[hypr-monitor]] #guide #linux
- [[GNU Radio On NixOS]] #guide #linux
- [[OBS on NixOS]] #guide #linux
- [[rpi-imager on NixOS]] #guide #linux
- [[Steam On NixOS]] #guide #linux
- [[STM32 NixOS Workflow]] #guide #linux

### QNX
- [[QNX-RaspberryPi5-SSH-Guide]] #guide #qnx
- [[Quick Start Target Image for Raspberry Pi]] #guide #qnx
- [[qnxide & qnxsc - NixOS]] #guide #qnx
- [[qnx-fhs]] #concept #qnx
- [[Makefile — QNX Server + Client Build Guide]] #guide #linux #qnx 
- [[Makefile — QNX Dual-Binary Build Guide]] #guide #linux #qnx 

---
## Books, Datasheets & Reference Manuals
- [[The C Programming Language]] #reference
- [[RM0368 Reference Manual]] #reference

---
## Tag Index
| Tag                | Purpose                           |
| ------------------ | --------------------------------- |
| `#todo`            | Incomplete / needs work           |
| `#concept`         | Theory, how-something-works       |
| `#guide`           | Step-by-step procedures           |
| `#project`         | Project-level notes               |
| `#microcontroller` | STM32, MCU-specific               |
| `#linux`           | Linux & NixOS notes               |
| `#qnx`             | QNX / RTOS notes                  |
| `#reference`       | Datasheets, register maps, lookup |
