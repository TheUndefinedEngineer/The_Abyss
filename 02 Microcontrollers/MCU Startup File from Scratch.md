*22-04-2026* 

A startup file is a piece of code written in assembly or C language that executes before the main() function of our embedded application. It performs various initialization steps by setting up the hardware of the microcontroller so that the user application can run.
## Importance of start-up file
- It is responsible for setting up the right environment for the main user code to run.
- The code written in startup file runs before `main()`, So the startup code calls `main()`.
- Some part of the startup code file is target (Processor) dependent - stack, heap, vector table addresses & sizes.
- It takes care of vector table placement in code memory, and stack reinitialization. 
- It is responsible for `.data`, and `.bss` section initialization in main memory.

## Steps in creating a Start-up file
1. Create a vector table for the micro-controller.
> [!important] Vector tables are MCU specific. Refer the reference manual.
2. Write a start-up code which initializes `.data` and `.bss` section in SRAM.
3. Call `main()`.

```bash
touch startup.c
```
### 1. Creating a Vector Table
- Create an array to hold MSP and handlers addresses.
- ```c
  uint32_t vectors[] = {store MSP and addresses of various handlers here};
  ```
> [!important] Instruct the compiler not include the above array in `.data` section but in a different user defined section. 

- Vector table to be in user-defined section so to change that refer *"section-name"*[^1]
![[vector table placement.png]]
```c
#include <stdint.h>

//use 'U' at end of a number to make it unsigned
#define SRAM_START <SRAM starting address>
#define SRAM_SIZE <SRAM size ex: 128* 1024 - 128KB>
#define SRAM_END ((SRAM_START) + (SRAM_SIZE))

#define STACK_START SRAM_END

void Reset_handler(void);

//Remeber we don't want this in .data
uint32_t vectors[] __attribute__ ((section("<section_name>"))) = {
	STACK_START,
	(uint32_t)&Reset_handler, //flow the sequence in the vector table
}; 

void Reset_handler(void){

}
```

Writing handlers for all the 97 exceptions will be tedious and not required. A single default handler for all the exceptions can be created and allows us to implement required handlers as per application requirements.

For this `gcc` function attributes - weak and alias are used:
- **Weak**: Lets us override the already defined weak function(dummy) with same function name.
- **Alias**: Lets us give alias name to a function.
```c
void Reset_Handler(void);

//making it (weak, alias()) allows us to override the funciton with same function name in main application. There we can implement real implementation of handling the exception.

void NMI_Handler(void) __attribute__((weak, alias("Default_Handler"))); // setting alias Default_Handler to the NMI_Handler.

void HardFault_Handler(void) __attribute__((weak, alias("Default_Handler"))); // setting alias Default_Handler to the HardFault_Handler.

uint32_t vectors[] __attribute__ ((section("<section_name>"))) = {
	STACK_START,
	(uint32_t)&Reset_Handler,
	(uint32_t)&NMI_Handler,
	(uint32_t)&HardFault_Handler,
	.
	.
	.
	0, //For reserved we should use 0, check the formal to calculate the number of 0's need depending on the address range.
	(uint32_t)&WWDG_IRQHandler, // IRQ is used for peripheral interrupts.
	// ',' should be present even for the last handler.
}; 

void Default_Handler(void){
	while(1);
}

void Reset_Handler(void){

}
```

> [!warning] The reserved space should be respected and 0 should be used to denote it in the vector table.

> [!important] Reserved: 0xXX – 0xYY -> No.of 0's = ((YY - XX) + 1) / 4 | ((ending addr. - starting addr.) + 1) / 4

> [!question] What's the difference b/w _Handler and _IRQHandler?
> - **`_Handler`**  
> 	- Used for **Cortex-M core exceptions**  
> 	- Examples: `Reset_Handler`, `HardFault_Handler`
> - **`_IRQHandler`**  
> 	- Used for **peripheral interrupts (NVIC)**  
> 	- Examples: `EXTI0_IRQHandler`, `USART2_IRQHandler`

- **System Exceptions (Core)**
	- Defined by ARM (Cortex-M4)
	- Fixed positions
	- Negative IRQ numbers

- **External Interrupts (Peripherals)**
	- Defined by STM32 (NVIC)
	- Start after system exceptions
	- IRQn ≥ 0

![[linker-startup.png]]

## Inspecting the Object File

After compiling, inspect the sections generated:

```bash
arm-none-eabi-objdump -h stm32f401_startup.o
```

### Command Breakdown

| Part | Meaning |
|---|---|
| `arm` | Target architecture is ARM |
| `none` | No operating system (bare metal) |
| `eabi` | Embedded Application Binary Interface |
| `objdump` | Tool that dumps info about object files |
| `-h` | Show section headers only |
| `stm32f401_startup.o` | The compiled object file to inspect |

### Other Useful Flags
| Flag | What it shows |
|---|---|
| `-h` | Section headers |
| `-d` | Disassembly of code |
| `-s` | Full contents of all sections |
| `-t` | Symbol table |

### What to Expect in the Output

| Section           | Destination        | Purpose                        |
| ----------------- | ------------------ | ------------------------------ |
| `.text`           | FLASH              | Your code/functions            |
| `.data`           | FLASH→SRAM         | Initialized global variables   |
| `.bss`            | SRAM               | Uninitialized global variables |
| `.isr_vector`     | FLASH (0x08000000) | Vector table                   |
| `.comment`        | Discarded          | Compiler metadata              |
| `.ARM.attributes` | Discarded          | ARM arch info                  |

> [!note] Note:
> All VMAs and LMAs will show `0x00000000` at this stage — this is normal! Real addresses are only assigned after the linker script runs.


---
## !
Sources:
1. https://youtu.be/2Hm8eEHsgls?si=cnz6XW9-btZlIMh9
2. https://microcontrollerslab.com/microcontrollers-startup-file-arm-cortex-m4-mcu/
3. [https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html](https://gcc.gnu.org/onlinedocs/)

Tags: 

[^1]: https://gcc.gnu.org/onlinedocs/gcc-14.3.0/gcc/Common-Variable-Attributes.html

