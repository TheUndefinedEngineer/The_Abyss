
*23/03/2026*

---
The main system consists of 32-bit multi-layer _AHB_  bus matrix that inter-connects:
- Six masters
	- Cortex®-M4 with FPU core I-bus, D-bus and S-bus
	- DMA1 memory bus
	- DMA2 memory bus
	- DMA2 peripheral bus
- Five slaves
	- Internal Flash memory ICode bus
	- Internal Flash memory DCode bus
	- Main internal SRAM
	- AHB1 peripherals including AHB to APB bridges and APB peripherals
	- AHB2 peripherals
The bus matrix provides access from master to slave - several high-speed peripherals work simultaneously.

The Cortex has 3 separate interfaces:

|Bus|Purpose|
|---|---|
|**I-bus**|Instruction fetch (Flash)|
|**D-bus**|Data access (SRAM, variables)|
|**S-bus (System bus)**|Peripheral access|
_This gives the total for 6 masters._

---
## I-Bus
This bus connects the instruction bus of the core to the BusMatrix. Used to fetch instructions. - internal flash memory/SRAM.

---
## D-Bus
This bus connects the data bus of the core to the BusMatrix. Used by the core for literal load and debug access. - internal flash memory/SRAM.

---
## S-Bus
This bus connects the system bus of the core to the BusMatrix. This
bus is used to access data located in a peripheral or in SRAM. Instructions may also be fetched on this bus (less efficient than ICode). - internal SRAM, the AHB1 peripherals including the APB peripherals and the AHB2 peripherals.

---
**Q. Difference b/w D-bus and S-bus?**
- **D-BUS → used for data**
    - Accesses **RAM / variables**
    - Example: `int x = arr[0];`
- **S-BUS → used for peripherals**
    - Accesses **hardware registers (GPIO, RCC, etc.)**
    - Example: `GPIOA->ODR = 1<<5;`

|Feature|D-BUS|S-BUS|
|---|---|---|
|Purpose|Data|Peripherals|
|Target|SRAM / Flash|Hardware registers|
|Usage|Variables|GPIO, RCC, etc|
|Type|“Normal memory”|“Memory-mapped hardware”|

---
## DMA Memory Bus

*DMA - Direct Memory Access*

This bus connects DMA memory bus master interface to the BusMatrix. Used by DMA to perform transfer to/from memories. - internal Flash/SRAM, and additionally for S4 the AHB1/AHB2 peripherals including the APB peripherals.

S4 - Stream 4 : DMA memory bus can also access peripherals. Meaning For Stream 4, DMA memory bus can also access peripherals (not just memory)

DMA memory bus is the DMA’s own path to access memory (and sometimes peripherals), while D-bus is the CPU’s path to access data in memory.

**"DMA memory bus = DMA data path, D-bus = CPU data path"**

---
*24/03/2026*

**Q. What is bus master interface?**
The hardware block that allows a unit (CPU/DMA) to initiate read/write operations on the bus

---
## DMA Peripheral Bus

This bus connects DMA memory bus master interface to the BusMatrix. Used by DMA to access AHB peripherals or to perform memory-to-memory transfers. - AHB, APB & data memories, flash and SRAM.

---
**Q. What is AHB & APB peripherals?**
AHB -> Advanced High-performance Bus (High speed)
- AHB peripherals are directly connected to high-speed high speed AHB bus.
- Faster access compared to APB.
- Used for Core-system stuff like:
	- GPIO
	- DMA
	- CRC

APB -> Advanced Peripheral Bus (Low speed compared to AHB)
- APB is slower peripherals and is used for communication and control like:
	- Timers
	- I2C
	- SPI
	- UART

---
## BusMatrix

Decides which master (CPU/DMA) gets access to the bus when multiple request it, using a round-robin turn system.

*Only a single master can access the bus path at a time.*

---
**Q. What is Round-Robin?**
Refers to a method or system where participants take turns in a cyclic, equitable manner. In context each master take turns to access the bus path.

![[system_arch.png]]

---
## AHB/APB Bridges

- AHB has one bridge.
- APB is split in 2 - faster & slower depending on the communication speed required by peripherals.
- Peripheral clocks are disabled after reset - Only Flash and SRAM won't be disabled.
- Before using any peripheral, its clock has to enabled in the **RCC_AHBxENR** or **RCC_APBxENR** register.
- *When a 16- or an 8-bit access is performed on an APB register, the access is transformed into a 32-bit access: the bridge duplicates the 16- or 8-bit data to feed the 32-bit vector.*

---
## Memory Organization

Program memory, data memory, registers and I/O ports are organized within the same linear 4 Gbyte address space.

The bytes are coded in memory in little "endian" format - [[Endianness]].
- Lower numbered byte -> LSB (Least significant Byte)
- Higher numbered byte -> MSB (Most significant Byte)

The addressable memory space is divided into 8 main blocks - *512* MB each.

The un-allocated memory and peripherals are considered *reserved*.

---
## Memory Map

- Organized layout of address space in a system, showing what each address corresponds to (RAM, ROM, peripherals, etc.)
- It provides the boundary address of peripherals 
```
Address Space
│
├── Program Memory (ROM/Flash)
├── Data Memory (RAM)
└── I/O / Peripherals
```

---
## Embedded SRAM

[[SRAM & PSRAM#What is SRAM?]]

The embedded SRAM can be accessed as bytes, half-words (16 bits) or full words (32 bits). Read and write operations are performed at CPU speed with 0 wait state.

The CPU can access the embedded SRAM through the System bus or through the I-Code/D-Code buses when boot from SRAM is selected or when physical remap is selected in the SYSCFG.

---
## Flash Memory

[[Flash Memory]]

The flash memory interface manages CPU AHB I-Code and D-Code accesses to the flash memory.

The flash memory is organized as follows:
- A main memory block divided into sectors.
- System memory from which the device boots in System memory boot mode
- 512 OTP (one-time programmable) bytes for user data.
- Option bytes to configure read and write protection, BOR level, watchdog software/hardware and reset when the device is in Standby or Stop mode.

---




Tags: #microcontroller #embedded #concepts 