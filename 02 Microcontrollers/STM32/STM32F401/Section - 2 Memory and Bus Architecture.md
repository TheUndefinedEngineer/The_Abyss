
*Start date: 23/03/2026*

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

## I-Bus
This bus connects the instruction bus of the core to the BusMatrix. Used to fetch instructions. - internal flash memory/SRAM.

## D-Bus
This bus connects the data bus of the core to the BusMatrix. Used by the core for literal load and debug access. - internal flash memory/SRAM.

## S-Bus
This bus connects the system bus of the core to the BusMatrix. This
bus is used to access data located in a peripheral or in SRAM. Instructions may also be fetched on this bus (less efficient than ICode). - internal SRAM, the AHB1 peripherals including the APB peripherals and the AHB2 peripherals.

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

## DMA Memory Bus

*DMA - Direct Memory Access*

This bus connects DMA memory bus master interface to the BusMatrix. Used by DMA to perform transfer to/from memories. - internal Flash/SRAM, and additionally for S4 the AHB1/AHB2 peripherals including the APB peripherals.

S4 - Stream 4 : DMA memory bus can also access peripherals. Meaning For Stream 4, DMA memory bus can also access peripherals (not just memory)

DMA memory bus is the DMA’s own path to access memory (and sometimes peripherals), while D-bus is the CPU’s path to access data in memory.

**"DMA memory bus = DMA data path, D-bus = CPU data path"**

#microcontroller #embedded 