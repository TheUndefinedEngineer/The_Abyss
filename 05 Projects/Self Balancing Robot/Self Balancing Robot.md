*21-03-2026*
```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```
---
## Project Hardware
- STM32F401CCU6
- IMU - MPU6500
- Bonka 7.4V 1300mAh 25C 2S LiPo
- N20 Micro-gear Motors w/ 34mm wheels
- TB6612FNG Motor Driver
- 3D printed base
---
## Pin Connections
### MPU6500

| PIN | STM32 |
| --- | ----- |
| VCC | 3.3V  |
| SCL | PB8   |
| SDA | PB9   |
| INT | PC13  |
| ADO | GND   |
### TB6612FNG

| PIN  | STM32 |
| ---- | ----- |
| AIN1 | PB3   |
| AIN2 | PB4   |
| BIN1 | PB5   |
| BIN2 | PB6   |
| PWMA | PA6   |
| PWMB | PA7   |
| STBY | 3.3V  |
| VM   | 7.4V  |
| VCC  | 3.3V  |
| AO1  | M1.1  |
| AO2  | M1.2  |
| BO1  | M2.1  |
| BO2  | M2.2  |
### Motor - 1

| PIN         | STM32  |
| ----------- | ------ |
| C1          | PA2    |
| C2          | PA3    |
| VCC         | 3.3/5V |
### Motor - 2

| PIN         | STM32  |
| ----------- | ------ |
| C1          | PB0    |
| C2          | PB1    |
| VCC         | 3.3/5V |

---
## Version History

### Version 1.0 & 1.1

Version 1.0 was intented to use 2 seprate PCB's - power board & main board but soon I realised it makes length of the robot very long which is not practical so, in version 1.1 I shifted everyhting to a single PCB. Both 1.0 & 1.1 used 2 Mini 360 buck converters for 3.3V and 5V power rails. But I faced the issue of not being able to adjust the voltage and they broke...

### Version 2.0 & 2.1

Version 2.0 I changed the Mini-360 buck to the more standard LM2596 DC-DC buck converters but I wasn't getting 2 different output rails 3.3v and 5v and both rails were outputing 5v for some reason which I couldn't figure out so, in version 2.1 I removed the 5v buck and wired everything to 3.3v which seemed to do the trick.

The reason I needed 5V was because the motor enocders were labeled VCC and I couldn't find any documentaion on them so, I wired them to 5v but not sure see if they will work with 3.3v as I still haven't tested them yet.

### Version 3

Version 3 is a redo of the whole hardware setup,the previous versions used hand-cut acrylic sheet for the base and oversized bolts&nuts(bought in a hardware store) to connect the PCB with the base which resulted in added weight along with imbalance. Therefore, in this version am using a 3D printed base, M3 screws which fit thourgh the PCB holes and a single non-variable 3.3v buck converter.

---
## Tools & Development
- Debian 13
- Neovim - [[Neovim]]
- Obsidian
- Make - [[SBR - Makefile]], [[A Guide on Makefiles]]
- arm-none-eabi-gcc
- OpenOCD - [[STM32F401 - OpenOCD Configuration]]
- GBD & Telnet - [[GDB - GNU Debugger]], [[Linux Commands#telnet]]
- [[SBR - Initial Setup]]
- [[SBR - Writing Code]]
---
## Current Progress

- Completed hardware connections but I forgot to redo the circuit diagram and also I have to search the 3D model which I created.
- I have gone through the reference manual - sections 2,3,5,6 and 8(a little).
- Started writing code - writing my own `Makefile`, `Startup file` and `linker file` at the moment and succesfully compiled an `.elf` file.
- Updated `linker script` to inlcude `ALIGN` and generated memory map - `test.map` to analyze how `.text`, `.data` and `.bss` sections are arranged in memory.
- Finished the `Reset_Handler()` by loading `.data` to memory and calling `main()`.
- Wrote `main.c` to blink the on-board led on `STM32F401CCU6` (PC13). Flashed the code using `openOCD` and `GDB`. Also learnt about `telnet`.
---








---
## Metadata
Sources:
1. [RM0368 Rev 6 - Reference manual](https://www.st.com/resource/en/reference_manual/rm0368-stm32f401xbc-and-stm32f401xde-advanced-armbased-32bit-mcus-stmicroelectronics.pdf)
2. [Makefile Guide](https://makefiletutorial.com/#getting-started)
3. [Officail GCC Documentation](https://gcc.gnu.org/onlinedocs/)
4. [Embedded Systems Programming - FastBit Academy](https://www.udemy.com/share/101Wdc3@q3zTlLfVGPCEW4a8bv7NjY2NR9K4dHKtHkx5YzrXL_R7W3licZ7vChKeaS9TfTxH9Q==/)
5. [OpenOCD Installation](https://www.youtube.com/watch?v=FNDp1G0bYoU&t=1029s)
6. [OpenOCD Github](https://github.com/openocd-org/openocd.git)
7. [GDB Commands Cheat Sheet](https://www.yolinux.com/TUTORIALS/GDB-Commands.html)
8. [OpenOCD General Commands](https://openocd.org/doc/html/General-Commands.html)

Tags: #project #reference 