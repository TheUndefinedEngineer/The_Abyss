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
### Creating a Vector Table
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


---
## !
Sources:
1. https://youtu.be/2Hm8eEHsgls?si=cnz6XW9-btZlIMh9
2. https://microcontrollerslab.com/microcontrollers-startup-file-arm-cortex-m4-mcu/
3. [https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html](https://gcc.gnu.org/onlinedocs/)

Tags: 

[^1]: https://gcc.gnu.org/onlinedocs/gcc-14.3.0/gcc/Common-Variable-Attributes.html

