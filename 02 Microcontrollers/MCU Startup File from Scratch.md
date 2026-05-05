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
	// copy .data section to SRAM
	
	// Init. the .bss section to zero in SRAM
	
	//call main()
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
[[Reading 'objdump -h' Output - ELF Section Headers]]
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

## `Reset_Handler`

```c
void Reset_Handler(void){
    // copy .data section to SRAM
    uint32_t size = &_edata - &_sdata;

    uint8_t *pDst = (uint8_t*)&_sdata;
    uint8_t *pSrc = (uint8_t*)&_etext;    
    for(uint32_t i = 0; i < size; i++){
        *pDst++ = *pSrc++;
    }

    // Init. the .bss section to zero in SRAM
    size = &_ebss - &_sbss;
    pDst = (uint8_t*)&_sbss;
    for(uint32_t i = 0; i < size; i++){
        *pDst++ = 0;
    }

    // call main();
    main();
}
```

> **Why this function exists:** The C standard assumes `.data` is already in RAM and `.bss` is already zeroed before `main()` runs. On a hosted system (Linux, Windows), the OS does this. On bare-metal STM32 there is no OS — you do it yourself, here, before calling `main()`. (RM0368 §2.4) [[Section - 2 Memory and Bus Architecture]]

---
### Where does this run in the boot sequence?

From RM0368 §2.4 — after reset the Cortex-M4 does two things automatically in hardware:
1. Reads `0x0000 0000` → loads it into **SP** (stack pointer) — top of stack
2. Reads `0x0000 0004` → loads it into **PC** (program counter) — first instruction
`0x0000 0000` is aliased to Flash `0x0800 0000`. The vector table sits there. The second entry in the vector table IS the address of `Reset_Handler`. So the CPU jumps here before any C code runs.

```
Power on / Reset
    ↓
CPU reads vector table[0] → SP = _estack
CPU reads vector table[1] → PC = &Reset_Handler
    ↓
Reset_Handler() runs      ← YOU ARE HERE
    ↓
main()
```

---
### Part 1 — Copy `.data` from Flash to SRAM

```c
uint32_t size = &_edata - &_sdata;
```

#### What are `_edata` and `_sdata`?

These are **linker script symbols** — names the linker binds to addresses. They are NOT variables. They have no storage. Taking `&_sdata` gives you the address the linker assigned to that symbol.

From your linker script: [[MCU Linker Scripts]]
```ld
.data :
{
    _sdata = .;        /* address of first byte of .data in SRAM */
    *(.data)
    . = ALIGN(4);
    _edata = .;        /* address one past the last byte of .data in SRAM */
} > SRAM AT> FLASH
```

So `&_edata - &_sdata` is pointer arithmetic that gives the **size in bytes** of the entire `.data` section. If `.data` occupies addresses `0x20000000` to `0x20000040`, size = `0x40` = 64 bytes.

```c
uint8_t *pDst = (uint8_t*)&_sdata;   // destination: start of .data in SRAM
uint8_t *pSrc = (uint8_t*)&_etext;   // source: where .data is stored in Flash
```

#### Why `uint8_t*`?
Because we want byte-by-byte precision. `size` is in bytes. Using `uint8_t*` means each `pDst++` and `pSrc++` advances exactly 1 byte — no accidental skipping of bytes that a `uint32_t*` would cause if size isn't a multiple of 4.

#### Why is the source `_etext`, not `_edata`?
This is the **LMA vs VMA** distinction from your linker script note.

|Symbol|What it is|
|---|---|
|`_sdata`|VMA — where `.data` **runs** (SRAM `0x2000 0000`)|
|`_edata`|VMA — end of `.data` in SRAM|
|`_etext`|LMA — where `.data` is **stored** in Flash, right after `.text`|

The linker places `.data` bytes physically in Flash (after all your code), but assigns them SRAM addresses. At boot, nothing has copied them yet — SRAM holds garbage. `pSrc` points to the Flash copy, `pDst` points to where they need to land in SRAM.

> [!important] What I understood after digging more:
> - `pSrc` starts at `_etext` — the LMA, the physical location in Flash where the `.data` bytes were baked into the binary by the linker
> - `pDst` starts at `_sdata` — the VMA, the SRAM address where your C code expects those variables to live
> - the loop walks both pointers forward byte by byte, replacing the garbage in SRAM with the real values from Flash
>   ```
>   pSrc (_etext)          pDst (_sdata)
>   ↓                      ↓
>   FLASH [ 0x05 ][ 0x0A ]    SRAM [ ?? ][ ?? ]   iteration 0: copy 0x05
>   FLASH [ 0x05 ][ 0x0A ]    SRAM [ 05 ][ ?? ]   iteration 1: copy 0x0A
>   FLASH [ 0x05 ][ 0x0A ]    SRAM [ 05 ][ 0A ]   done
>   ```
>   
The only thing worth locking in: the linker never "links" the two sides automatically at runtime — it just **records** both addresses. The physical copying only happens because your `Reset_Handler` loop manually walks from one to the other. Without that loop, the VMA side stays garbage forever and `main()` would read wrong values from every initialized global.

```
FLASH layout:
0x08000000  [ .isr_vector ]
            [ .text       ]
            [ .rodata     ]
_etext -->  [ .data copy  ]  ← pSrc starts here
            (LMA of .data)

SRAM layout:
0x20000000  [ .data       ]  ← pDst starts here (_sdata)
            ...
_edata  -->
            [ .bss        ]
```

```c
for(uint32_t i = 0; i < size; i++){
    *pDst++ = *pSrc++;
}
```

A simple byte-copy loop. Each iteration:

- reads 1 byte from Flash (`*pSrc`)
- writes 1 byte to SRAM (`*pDst`)
- advances both pointers by 1

After this loop: every initialized global variable in your program has its correct starting value in SRAM.

> [!important] This is why `ALIGN(4)` around `_sdata` and `_edata` in the linker script matters — if the symbols aren't aligned, the copy loop still works byte-by-byte, but any subsequent 32-bit access to a `.data` variable could cause a bus fault or data corruption on Cortex-M4.

---
### Part 2 — Zero out `.bss`

```c
size = &_ebss - &_sbss;
```

Same pointer subtraction trick — gives size in bytes of the `.bss` section.

`.bss` holds **uninitialized global and static variables**. The C standard guarantees they start as zero. Flash doesn't store zeros for `.bss` (there's nothing to store — that's the point, they take no space in the binary). So we must zero them in SRAM ourselves.

```c
pDst = (uint8_t*)&_sbss;
for(uint32_t i = 0; i < size; i++){
    *pDst++ = 0;
}
```

From your linker script:
```ld
.bss :
{
    _sbss = .;
    *(.bss)
    _ebss = .;
} > SRAM
```

`_sbss` = first byte of `.bss` in SRAM. Loop writes `0` to every byte from `_sbss` to `_ebss`.

After this loop: all your uninitialized globals are guaranteed to be `0`.

#### Why does this matter?

```c
// global scope — goes in .bss
int counter;          // C guarantees this is 0 at startup
uint8_t buffer[256];  // C guarantees all 256 bytes are 0

void main(void) {
    // if Reset_Handler didn't zero .bss:
    // counter and buffer could contain random Flash/SRAM garbage
}
```

---
### Part 3 — Call `main()`

```c
main();
```

Only after `.data` is copied and `.bss` is zeroed is the C environment valid. Now `main()` can safely use global variables, static locals, and any initialized data.

> [!warning] `main()` on bare-metal should **never return**. There is no OS to return to. If `main()` returns, the CPU executes whatever is in memory after `Reset_Handler` — undefined behavior. Add an infinite loop as a safety net:
> 
> c
> 
> ```c
> main();
> while(1); // should never reach here
> ```

---
## Full picture — memory state before and after Reset_Handler

```
             FLASH (read-only)          SRAM (garbage on power-on)
             ──────────────────         ──────────────────────────
0x08000000   [ isr_vector     ]
             [ .text / code   ]         0x20000000  [ ??? garbage ]  ← .data VMA
             [ .rodata        ]
_etext →     [ .data IMAGE    ]  copy→  _sdata      [ correct vals]  ← after loop 1
             (LMA, stored here)         _edata
                                        _sbss       [ 0x00 0x00.. ]  ← after loop 2
                                        _ebss
                                        [ heap ↑    ]
                                        [ stack ↓   ]
             ──────────────────         0x20010000
```

---
## !
Sources:
1. https://youtu.be/2Hm8eEHsgls?si=cnz6XW9-btZlIMh9
2. https://microcontrollerslab.com/microcontrollers-startup-file-arm-cortex-m4-mcu/
3. [https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html](https://gcc.gnu.org/onlinedocs/)

Tags: 

[^1]: https://gcc.gnu.org/onlinedocs/gcc-14.3.0/gcc/Common-Variable-Attributes.html

