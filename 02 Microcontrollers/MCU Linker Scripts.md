*29-04-2026* 

## Introduction
It is a text file which explains how different sections of the object files should be merged to create an output file.

Linker and locator combination assigns unique absolute addresses to different sections of the output file by referring to address information mentioned in the linker script.

It also includes the code and data memory address and size information and written using the GNU linker command language.

It uses the file extension of `.ld` and linker script should be supplied at the linking phase to the linker using `-T` option.

[[MCU Startup File from Scratch]]

---
## Commands
- ENTRY
- MEMORY
- SECTIONS
- KEEP
- ALIGN
- AT>

### ENTRY
- It is used to set the "Entry point address" information in the header of final elf file generated.
- "Reset_Handler" is the entry point into the application in case of STM32. The first piece of code that executes right after the processor reset.
- The debugger uses this information to locate the first function to execute.
- Not a mandatory command to use but required when you debug the elf file using the debugger (GDB)
- Syntax: `Entry(_symbol_name_)`
```bash
Entry(Reset_Handler)
```

### Memory
- It allows us to describe the different memories present in the target and their start address and size information.
- The linker uses information mentioned in this command to assign addresses to merged sections.
- The information is given under this command also helps the linker to calculate total code and data memory consumed so far and throw an error message if data, code, heap or stack areas can't fit into available size.
- By using memory command, we can fine-tune various memories available in your target and allow different sections to occupy different memory areas.
- Typically one linker script has one memory command.
- Syntax: 
```
MEMORY
{
	name(attr):ORIGIN = origin, LENGTH = len
}
```
- `name(attr)`: defines name of the memory region which will be later referenced by other parts of the linker script.
- `ORIGIN`: defines origin address of the memory region.
- `LENGTH`: defines the length information.
- `(attr)`: defines the attribute list of the memory region valid attribute lists must be made up of the characters "ALIRWX" that match section attributes.

| Attribute Letter | Meaning                                             |
| ---------------- | --------------------------------------------------- |
| R                | Read-only sections                                  |
| W                | Read and write sections                             |
| X                | Sections containing executable code                 |
| A                | Allocated sections                                  |
| I                | Initialized sections                                |
| L                | Same as 'I'                                         |
| !                | Invert the sense of any of the following attributes |
> [!important] The attr letters can be of any case and multiple letters can be used at a time.

### SECTIONS
- It is used to create different output sections in the final elf executable generated.
- Important command by which we can instruct the linker how to merge the input sections to yield an output section.
- It also controls the order in which different output sections appear in the elf file generated.
- By using this command, we can also mention the placement of a section in a memory. Ex: We can instruct linker to place the `.text` section in the FLASH memory region, which is described by the memory command.
```
SECTIONS
{
	/* This section should include .text section of all input files */
	.text:
	{
		//merge all .isr_vector section of all input files
		//merge all .text section of all input files
		//merge all .rodata section of all input files
	} >(vma)AT>(lma)
	
	/* Symbols */
	__max_heap_size = 0x400;
	__max_stack_size = 0x200;
	
	/* This section should include .data section of all input files */
	.data:
	{
		//here merge all .data section of all input files
	} >(vma)AT>(lma)
	
	/* This section should include .bss - uninitalized data */
	.bss:
	{
		//here merge all .bss section of all uninialized data.
	} >(vma) // it only has vma no lma
}
```

![[storage of final executable in code memory.png]]

- In `.text` section we have to merge all the object files like:  main.o, led.o, startup.o. To do this we have to use a short-hand notation using wildcard character - `*(.text)`
> [!question] What is `.rodata`?
> `.rodata` is where the compiler puts **constants that can never change** - it lives in **Flash**, right next to user code.
- `vam` - virtual memory address
- `lma` - load memory address
- `.text` - stores in Flash and as its not relocated in startup code and therefore `vma` and `lma` are same.
```
}> vma AT> lam -> }> FLASH AT> FLASH
or
}> FLASH : meaning vma and lma are same
```
- The linker generates absolute addresses which falls in `vma` region and it also generated load addresses which falls under `lma`.

![[relocating (.)data.png]]

## Location counter(.)
- To relocate the `.data` we need the size and start address / `.rodata` ending address
- And this is where location counter comes in, it is a special linker symbol denoted by a dot `.`.
- The symbol is called `location counter` since linker automatically updates this symbol with location(address) information.
- It can be used inside the linker script to track and define boundaries of various sections.
- It can also be used to set location counter to any specific value while writing linker script.
- It should only appear in `SECTIONS` command.
- It is incremented by the size of the output section.

## Linker script symbol
- A symbol is the name of an address
- A symbol declaration is not equivalent to a variable declaration what we do in our 'C' program.
![[symbol table.png]]

- The boundary information `_etext`, `_sdata`, and `_edata` has to be stored somewhere which is the symbols.
- A symbol is name given for an address.
> [!important] Location counter always tracks VMA of the section in which it is being used.

---
## The MEMORY block

Defines the physical regions of your chip. Everything must fit inside these.

```ld
MEMORY
{
    FLASH(rx) : ORIGIN = 0x08000000, LENGTH = 256K
    SRAM(rwx) : ORIGIN = 0x20000000, LENGTH = 64K
}
```

> **STM32F401xB/C** — 256K Flash, 64K SRAM (RM0368 §2.3.1)  
> Fastbit uses STM32F407 (1024K Flash, 128K SRAM) — adjust for your chip.

> [!warning] Remember to give space after `ORIGIN` and `LENGTH`


---
## The SECTIONS block

Maps compiled output sections to physical memory regions.

```ld
SECTIONS
{
    .text :
    {
        *(.isr_vector)   /* vector table MUST be first in FLASH */
        *(.text)         /* all code */
        *(.rodata)       /* string literals, const data */
        end_of_text = .; /* location counter saved as symbol */
    } > FLASH

    .data :
    {
        start_of_data = 0x20000000;
        *(.data)         /* initialized global variables */
    } > SRAM AT> FLASH   /* runs in SRAM, stored in FLASH */

    .bss :
    {
        *(.bss)          /* zero-initialized globals */
    } > SRAM
}
```

### Why `.isr_vector` must be first

The Cortex-M4 always reads the vector table from `0x08000000` on reset (RM0368 §2.4). If it's not first in FLASH, the CPU boots into garbage.

### What `AT> FLASH` means

- **VMA** (Virtual Memory Address) — where it _runs_: SRAM
- **LMA** (Load Memory Address) — where it _lives_ in the binary: FLASH

Initialized globals are stored in FLASH and copied to SRAM by startup code at boot. `.bss` doesn't need space in FLASH — startup code just zeroes it in SRAM.

---
## Heap & Stack symbols

```ld
__max_heap_size  = 0x200;   /* 512B  */
__max_stack_size = 0x800;   /* 2KB   */
```

> These are **symbols** (names bound to a value by the linker), NOT variables.  
> They are a contract between the linker script and the startup code.

### Who uses them

**Not your code.** The startup code reads them before `main()` runs to verify heap + stack fit in SRAM.

### What happens if you omit them

Nothing breaks at link time. But you lose the boot-time safety check. Stack can silently overflow into `.bss`/`.data` with no warning — corrupted globals, unpredictable behavior.

### Boot sequence

```
Reset
  ↓
startup code         ← checks __max_heap_size + __max_stack_size
  ↓
copy .data FLASH → SRAM
  ↓
zero out .bss
  ↓
main()
```

---
## SRAM layout

```
0x20010000  ┌──────────────────┐  ← top of SRAM
            │   stack  ↓       │  starts here, grows DOWN
            ├ ─ ─ ─ ─ ─ ─ ─ ─--┤
            │   free space     │  danger zone — they close in
            ├ ─ ─ ─ ─ ─ ─ ─ ─ -┤
            │   heap   ↑       │  starts after .bss, grows UP
            ├──────────────────┤
            │   .bss           │  zeroed globals
            ├──────────────────┤
            │   .data          │  initialized globals (copied from FLASH)
0x20000000  └──────────────────┘  ← bottom of SRAM
```

Stack and heap grow toward each other. If they collide → **stack overflow**. No hardware barrier between them — collision corrupts data silently.

---
## Stack vs Heap

|                | Stack                      | Heap                          |
| -------------- | -------------------------- | ----------------------------- |
| Managed by     | Compiler / CPU             | User                          |
| Allocation     | Automatic on function call | Manual via `malloc()`         |
| Freed          | When function returns      | When you call `free()`        |
| Speed          | Very fast (just moves SP)  | Slower (searches free blocks) |
| Risk           | Stack overflow             | Memory leak / fragmentation   |
| Bare metal use | Always                     | Avoid if possible             |
### Stack — what goes on it
- Local variables inside functions
- Function return addresses
- Saved registers
- ISR auto-push: 8 registers = 32 bytes every interrupt (Cortex-M4 architecture)

### Heap — avoid on bare metal
`malloc` can fail silently. Fragmentation can cause failure after days of uptime with no warning. Prefer static allocation.

---
## Choosing sizes

### Stack
- How many nested function calls deep?
- Using interrupts? (+32 bytes minimum per ISR, auto-pushed by CPU)
- Any large local arrays? (e.g. `char buf[512]` eats 512 bytes of stack)

**Safe default for STM32F401:**

```ld
__max_stack_size = 0x800;  /* 2KB */
```

### Heap
**No `malloc`? → set to zero:**

```ld
__max_heap_size = 0x0;
```

**Using `malloc`? → add up your allocations + headroom.**

### SRAM budget check

```
.data + .bss + heap + stack ≤ 64KB
~1KB  + ~1KB + 0KB  + 2KB  = ~4KB used
                              60KB free  ✓
```

---
## Hex size quick reference

|Hex|Bytes|Size|
|---|---|---|
|`0x200`|512|512B|
|`0x400`|1024|1KB|
|`0x800`|2048|2KB|
|`0x1000`|4096|4KB|
|`0x2000`|8192|8KB|
|`0x10000`|65536|64KB — full SRAM|
### The shortcut

`0x400` = 1KB. Memorize this anchor. Everything else is doubling or halving:

```
0x400 × 2 = 0x800  = 2KB
0x800 × 2 = 0x1000 = 4KB
0x400 ÷ 2 = 0x200  = 512B
```

### Why 1024 not 1000?

Computers work in powers of 2. `2^10 = 1024` is the cleanest boundary in binary — 10 bits all flipping at once. 1000 has no special meaning in binary. "K" in computing = 1024 (not 1000 like metric).

---
## Complete linker script (STM32F401)

```ld
ENTRY(Reset_Handler)

MEMORY
{
    FLASH(rx) : ORIGIN=0x08000000, LENGTH=256K
    SRAM(rwx) : ORIGIN=0x20000000, LENGTH=64K
}

__max_heap_size  = 0x200;
__max_stack_size = 0x800;

SECTIONS
{
    .text :
    {
        *(.isr_vector)
        *(.text)
        *(.rodata)
        end_of_text = .;
    } > FLASH

    .data :
    {
        start_of_data = 0x20000000;
        *(.data)
    } > SRAM AT> FLASH

    .bss :
    {
        *(.bss)
    } > SRAM
}
```

---
## Key concepts

> **Symbol** — a name the linker binds to an address or value. Not a variable. Has no storage. Used as a reference point by startup code.

> **Location counter (`.`)** — the current address the linker is placing things at. `end_of_text = .` captures it as a symbol at that moment.

> **VMA vs LMA** — VMA is where code _runs_, LMA is where it _lives_ in the binary. They differ for `.data` because initialized globals must be stored in FLASH but executed from SRAM.
---
## !
Sources:
1. https://www.udemy.com/course/embedded-system-programming-on-arm-cortex-m3m4/?referralCode=12E4B80663C357C4F867

Tags: #reference #microcontroller 
