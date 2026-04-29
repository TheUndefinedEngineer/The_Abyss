*29-04-2026* 

## Introduction
It is a text file which explains how different sections of the object files should be merged to create an output file.

Linker and locator combination assigns unique absolute addresses to different sections of the output file by referring to address information mentioned in the linker script.

It also includes the code and data memory address and size information and written using the GNU linker command language.

It uses the file extension of `.ld` and linker script should be supplied at the linking phase to the linker using `-T` option.

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
	
	/* This section should include .data section of all input files */
	.data:
	{
		//here merge all .data section of all input files
	} >(vma)AT>(lma)
}
```



---
## !
Sources:
1. 

Tags: