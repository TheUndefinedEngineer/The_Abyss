*24-04-2026* 

[[A Guide on Makefiles]]

```make
CC = arm-none-eabi-gcc
MACH = cortex-m4
CFLAGS = -mcpu=$(MACH) -mthumb -std=gnu11 -Wall -O0 -c
LDFLAGS = -nostdlib -T stm32f401_ls.ld -Wl,-Map=test.map

all: stm32f401_startup.o main.o test.elf

stm32f401_startup.o:stm32f401_startup.c
	$(CC) -c $(CFLAGS) $^ -o $@
	
main.o:main.c
	$(CC) -c $(CFLAGS) $^ -o $@
	
test.elf: main.o stm32f401_startup.o 
	$(CC) $(LDFLAGS) $^ -o $@
	
clean:
	rm -rf *.o *.elf
```

---
1. `CC = arm-none-eabi-gcc` -> Sets the compiler
   
2. `MACH = cortex-m4` -> Stores target CPU, just a variable
   
3. `CFLAGS = -c -mcpu=$(MACH) -mthumb -std=gnu11 -Wall -O0`
	1. **mcpu=$(MACH) → -mcpu=cortex-m4** -> Targets the Cortex-M4 CPU and ensures correct instruction generation
	2. **-mthumb** -> Uses Thumb instruction set which is required for Cortex-M microcontrollers
	3. **-std=gnu11** -> Uses GNU C11 standard and supports modern C features + GNU extensions
	4. **-Wall** -> Enables compiler warnings and helps catch bugs early
	5. **-O0** -> No optimization, makes debugging easier and more predictable execution.
	6. **-c** -> Compile only (no linking), Produces `.o` (object file)

4. `all: stm32f401_startup.o` -> - Default target, running `make` builds this file.

5. `stm32f401_startup.o: stm32f401_startup.c` -> .o file is dependent on the .c file.

6. `$(CC) -c $(CFLAGS) $^ -o $@` -> 
```bash
arm-none-eabi-gcc -c -mcpu=cortex-m4 -mthumb -std=gnu11 -Wall -o0 -c stm32f401_startup.c -o stm32f401_startup.0
```
Special variables:
- `$^` → all dependencies → `stm32f401_startup.c`
- `$@` → target → `stm32f401_startup.0`

7. clean:
		rm -rf *.o *.elf -> when `make clean` is use object files `.o` and binary files `.elf` gets deleted.

```c
$(CC)     -c     $(CFLAGS)     $^          -o     $@
  |        |         |          |            |      |
use this  compile  with these  these files  name   this
compiler  only     flags       as input     it     filename
```

---
## LDFLAGS — Linker Flags

```makefile
LDFLAGS = -nostdlib -T stm32f401_ls.ld -Wl,-Map=test.map
```

> [!question] **What is LDFLAGS?** 
> `LDFLAGS` is a Makefile variable that passes options to the **linker** (`ld`). The linker takes all compiled `.o` object files and merges them into a single `.elf` binary — placing each section (`.text`, `.data`, `.bss`) at the exact memory address the STM32 hardware expects.

---
### `-nostdlib`

**What it does:** Tells GCC to **not link** the standard C library (`libc`), math library (`libm`), or the C runtime startup (`crt0`).

**Why we need it on bare-metal:**

- On a bare-metal STM32 there is no OS, no heap manager, and no `main()` bootstrapper from libc.
- You write your own startup code: vector table, stack init, copy `.data` from Flash → SRAM.
- Without `-nostdlib`, the linker tries to pull in glibc symbols that simply don't exist on the MCU and fails.

> See **RM0368 §2.4** — Boot configuration. [[Section - 2 Memory and Bus Architecture]]

---
### `-T stm32f401_ls.ld`

**What it does:** Provides a **linker script** that maps ELF sections to the STM32F401's actual memory regions.

**Why we need it:** Without a linker script, the linker has no idea where Flash starts or how big SRAM is. The script defines:

- `MEMORY{}` — names and sizes of physical memory regions (from RM0368 §2.3)
- `SECTIONS{}` — which ELF section goes where

### Memory regions (from RM0368 §2.3 Memory Map)

|Region|Start Address|End Address|Size|Sections placed here|
|---|---|---|---|---|
|Flash|`0x0800 0000`|`0x0803 FFFF`|256 KB|`.isr_vector` `.text` `.rodata`|
|SRAM|`0x2000 0000`|`0x2000 FFFF`|64 KB*|`.data` `.bss` `.stack`|

> * STM32F401xB/C = 64 KB SRAM | STM32F401xD/E = 96 KB SRAM — RM0368 §2.3.1

> [!WARNING] The Cortex-M4 fetches the reset vector from `0x0000 0000`, which is aliased to Flash `0x0800 0000` on boot. If your linker script places the vector table anywhere else, the MCU will not boot. See **RM0368 §2.4**.

---
### `-Wl,-Map=test.map`

**What it does:** Generates a **memory map file** (`test.map`) alongside the binary.

**Breaking it down:**
- `-Wl,` — GCC prefix meaning "pass the next option directly to the linker, don't process it yourself"
- `-Map=test.map` — the actual linker flag, output a map file named `test.map`

**What the `.map` file shows you:**
- Exact address of every function and variable
- Size of each section (`.text`, `.data`, `.bss`)
- Which object file contributed each symbol
- Total Flash and SRAM usage

**Typical use cases:**
- "Why is my binary too big?" → check section sizes
- "Is my ISR actually in Flash?" → check `.isr_vector` placement
- "Where is my stack?" → find `_estack` symbol address

---
## Mental Model — The Full Pipeline

```
your_code.c
    │
    ▼  gcc -c (compiler)
your_code.o  +  startup.o  +  other.o
    │
    ▼  ld + LDFLAGS (linker)
    │   ├── -nostdlib        → no libc bloat
    │   ├── -T *.ld          → correct memory layout
    │   └── -Wl,-Map=...     → map file side output
    │
    ├──▶  firmware.elf       (flash to MCU)
    └──▶  test.map           (inspect in text editor)
```



---
## !
Sources:
1. 

Tags: #reference #project #microcontroller 