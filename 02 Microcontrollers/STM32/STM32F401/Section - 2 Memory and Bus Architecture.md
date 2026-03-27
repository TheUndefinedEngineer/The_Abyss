*23/03/2026*

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
*26/03/2026*
## Bit Banding

[[Bit Banding]]

The Cortex®-M4 with FPU memory map includes two bit-band regions.

bit_word_addr is the address of the word in the alias memory region that maps to the targeted bit
- bit_band_base is the starting address of the alias region
- byte_offset is the number of the byte in the bit-band region that contains the targeted bit
- bit_number is the bit position (0-7) of the targeted bit

---
*27/03/2026*
## Boot Configuration

The Cortex-M4 CPU has a **hardwired behavior** on reset:

1. It always reads the **stack pointer** from address `0x0000 0000`
2. It always reads the **reset vector** (first instruction to jump to) from `0x0000 0004`
3. This fetch happens over the **ICode bus**, which only reaches the _code area_ of the memory map

This means whatever you want to boot from **must appear at `0x0000 0000`** — but physically, Flash lives at `0x0800 0000` and SRAM at `0x2000 0000`. So how do you boot from them

**The Solution: Address Aliasing**

STM32 uses a trick called **aliasing** — the boot mechanism _remaps_ a selected memory region to appear at `0x0000 0000`, without moving anything physically.

| BOOT1 | BOOT0 | Boot Source         | What gets aliased to `0x0000 0000` |
| ----- | ----- | ------------------- | ---------------------------------- |
| x     | 0     | Main Flash          | `0x0800 0000` → `0x0000 0000`      |
| 0     | 1     | System Memory (ROM) | Bootloader ROM → `0x0000 0000`     |
| 1     | 1     | Embedded SRAM       | `0x2000 0000` → `0x0000 0000`      |
The CPU always fetches from `0x0000 0000`. The BOOT pins just control what _physically backs_ that address.

**The Three Boot Modes Explained**

**1. Main Flash Memory (BOOT0 = 0)** The most common mode. Your compiled application sits in Flash at `0x0800 0000`, and Flash is aliased to `0x0000 0000`. Normal production use.

**2. System Memory (BOOT1=0, BOOT0=1)** Boots ST's **factory-programmed bootloader** embedded in a read-only ROM. Used to flash the chip over UART/USB/I2C/SPI without a debugger. You use this when you brick your Flash or want to do field updates.

**3. Embedded SRAM (BOOT1=1, BOOT0=1)** SRAM is aliased to `0x0000 0000`. Used during **development/debugging** — you can rapidly download and run code without wearing out Flash write cycles.

**Timing: When Are BOOT Pins Sampled**

```
Reset asserted
      │
      ▼
  [4th rising edge of SYSCLK]  ← BOOT pins latched HERE
      │
      ▼
  CPU reads stack pointer from 0x0000 0000
      │
      ▼
  CPU jumps to reset handler at 0x0000 0004
```

The pins are also **re-sampled on Standby exit**, so you can't float or change them while the device is in Standby mode.

**BOOT0 vs BOOT1 Pin Behaviour**
- **BOOT0** is a **dedicated pin** — it only serves the boot selection function
- **BOOT1** is **shared with a GPIO** — after the boot pins are sampled, BOOT1's GPIO is fully released and your code can use it as a normal I/O pin

> [!important] Key insight
> When booting from SRAM, there's an extra burden on your startup code. Normally the **vector table** (interrupt vectors, fault handlers) sits in Flash. But now SRAM is the boot space, so we must **manually** relocate the vector table into **SRAM** and tell the NVIC about it:
> ```c
SCB->VTOR = SRAM_BASE | VECT_TAB_OFFSET; 
//           ^             ^ 
//         0x2000 0000   offset must be 512-byte aligned

---
## Embedded bootloader

The embedded bootloader mode is used to reprogram the flash memory using one of the following serial interfaces:
- USART1 (PA9/PA10)
- USART2 (PD5/PD6)
- I2C1 (PB6/PB7)
- I2C2 (PB10/PB3)
- I2C3 (PA8/PB4)
- SPI1 (PA4/PA5/PA6/PA7)
- SPI2 (PB12/PB13/PB14/PB15)
- SPI3 (PA15/PC10/PC11/PC12)
- USB OTG FS (PA11/12) in Device mode (DFU: device firmware upgrade).
The USART peripherals operate at the internal 16 MHz oscillator (HSI) frequency, while the USB OTG FS require an external clock (HSE) multiple of 1 MHz (ranging from 4 to 26 MHz).

The embedded bootloader code is located in system memory. It is programmed by ST during production. For additional information, refer to application note AN2606.

> [!important] Key insight 
> ST burns a small flash programmer permanently into a protected ROM (System Memory) on every STM32. Its only job is to let you flash your code **without an ST-Link debugger**.

---
## STM32F401 Physical Remap

**Two Levels of Boot Control**

This is where it gets nuanced. There are actually **two separate mechanisms** that control what appears at `0x0000 0000`:

```
Level 1 — Hardware:  BOOT pins → set at reset, selects initial alias
Level 2 — Software:  SYSCFG_MEMRMP register → code can change it later
```

The BOOT pins gives the starting point. But once the application is running, it can **reprogram the alias in software** — without any pin changes or reset.

```c
// Example: remap SRAM to 0x0000 0000 in software
SYSCFG->MEMRMP = 0x03;  // 11 = SRAM
SYSCFG->MEMRMP = 0x01;  // 01 = System memory
SYSCFG->MEMRMP = 0x00;  // 00 = Flash (default)
```
### Reading the Memory Map Table

Let's decode Table 3 (xB/C — 256KB Flash, 64KB SRAM):

| Address Range | Always There | What Changes |
|---|---|---|
| `0x2000 0000` | SRAM1 (64KB) | Never moves — always at this address |
| `0x1FFF 0000` | System Memory | Never moves — always at this address |
| `0x0800 0000` | Flash | Never moves — always at this address |
| `0x0000 0000` | **ALIAS ZONE** | ← This is what changes |

The alias zone at `0x0000 0000` is the only thing that shifts:
```
Boot/Remap = Flash    →  Flash (256KB) aliased at 0x0000 0000
Boot/Remap = SRAM     →  SRAM1 (64KB) aliased at 0x0000 0000  
Boot/Remap = System   →  System memory (30KB) aliased at 0x0000 0000
```

> [!important] Key insight
> The original memory is **still accessible at its real address** even when aliased.
> Flash is always at `0x0800 0000`. SRAM is always at `0x2000 0000`.
> The alias at `0x0000 0000` is just an **extra window** into the same physical memory.
### xB/C vs xD/E Difference

Simply more memory on the larger variant:

| Variant | Flash | SRAM1 | Alias zone size |
|---|---|---|---|
| STM32F401xB/C | 256 KB | 64 KB | `0x0000 0000 – 0x0003 FFFF` |
| STM32F401xD/E | 512 KB | 96 KB | `0x0000 0000 – 0x0007 FFFF` |
The alias zone grows to accommodate the larger Flash.
### Why Would You Remap in Software?

The most common real use case is **bootloader → application handoff**:
1. The custom bootloader starts (booted from Flash)
2. It receives a new firmware image over UART
3. It writes the new image to a specific Flash region
4. It remaps memory via SYSCFG_MEMRMP to point to new code
5. It resets the stack pointer and jumps to new reset vector
6. Application runs — no pin changes, no physical reset needed

Another use case — **SRAM-based interrupt handling**:
```
Remap SRAM to 0x0000 0000
        │
        ▼
Place vector table in SRAM
        │
        ▼
Patch interrupt vectors at runtime (useful for dynamic dispatch)
        │
        ▼
ICode bus fetches vectors from SRAM as if it were code memory
```

Full Picture Together
```
BOOT pins (hardware, at reset)
        │
        ▼
Initial alias set → CPU starts executing
        │
        ▼
SYSCFG_MEMRMP (software, anytime)
        │
        ▼
Alias can be changed → different memory now at 0x0000 0000
        │
        ▼
Real addresses (0x0800 0000, 0x2000 0000) always remain accessible
```

Tags: #microcontroller #concept 