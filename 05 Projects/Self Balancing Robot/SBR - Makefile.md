*24-04-2026* 
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
[[A Guide on Makefiles]]

---
## Version 1

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
### LDFLAGS — Linker Flags

```makefile
LDFLAGS = -nostdlib -T stm32f401_ls.ld -Wl,-Map=test.map
```

> [!question] **What is LDFLAGS?** 
> `LDFLAGS` is a Makefile variable that passes options to the **linker** (`ld`). The linker takes all compiled `.o` object files and merges them into a single `.elf` binary — placing each section (`.text`, `.data`, `.bss`) at the exact memory address the STM32 hardware expects.

---
#### `-nostdlib`

**What it does:** Tells GCC to **not link** the standard C library (`libc`), math library (`libm`), or the C runtime startup (`crt0`).

**Why we need it on bare-metal:**

- On a bare-metal STM32 there is no OS, no heap manager, and no `main()` bootstrapper from libc.
- You write your own startup code: vector table, stack init, copy `.data` from Flash → SRAM.
- Without `-nostdlib`, the linker tries to pull in glibc symbols that simply don't exist on the MCU and fails.

> See **RM0368 §2.4** — Boot configuration. [[Section - 2 Memory and Bus Architecture]]

---
#### `-T stm32f401_ls.ld`

**What it does:** Provides a **linker script** that maps ELF sections to the STM32F401's actual memory regions.

**Why we need it:** Without a linker script, the linker has no idea where Flash starts or how big SRAM is. The script defines:

- `MEMORY{}` — names and sizes of physical memory regions (from RM0368 §2.3)
- `SECTIONS{}` — which ELF section goes where

#### Memory regions (from RM0368 §2.3 Memory Map)

|Region|Start Address|End Address|Size|Sections placed here|
|---|---|---|---|---|
|Flash|`0x0800 0000`|`0x0803 FFFF`|256 KB|`.isr_vector` `.text` `.rodata`|
|SRAM|`0x2000 0000`|`0x2000 FFFF`|64 KB*|`.data` `.bss` `.stack`|

> * STM32F401xB/C = 64 KB SRAM | STM32F401xD/E = 96 KB SRAM — RM0368 §2.3.1

> [!WARNING] The Cortex-M4 fetches the reset vector from `0x0000 0000`, which is aliased to Flash `0x0800 0000` on boot. If your linker script places the vector table anywhere else, the MCU will not boot. See **RM0368 §2.4**.

---
#### `-Wl,-Map=test.map`

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
### Mental Model — The Full Pipeline

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
## Version 2

```make
# Cleanup
RM := rm -rf

# Tools
CC        = arm-none-eabi-gcc
OBJDUMP   = arm-none-eabi-objdump
SIZE      = arm-none-eabi-size

# Project Name
TARGET    = SBR

# Linker Script
LD_SCRIPT = stm32f401_ls.ld

# Flags
CPU_FLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard

CFLAGS    = $(CPU_FLAGS) -O0 -g3 -Wall -ffunction-sections -fdata-sections

LDFLAGS  = $(CPU_FLAGS) -T$(LD_SCRIPT) -Wl,-Map=$(TARGET).map -Wl,--gc-sections \
	   -static -u _printf_float -Wl,--defsym=end=0

# -------------------------------------
#  LIST OF SOURCE FILES
#  ------------------------------------

SRCS     = Core/Src/main.c \
	   Core/Startup/stm32f401_startup.c

# Include Paths
# INCLUDES = -ICore/Inc

# -------------------------------------
#  Auto-generate .o list from SRCS
# -------------------------------------
OBJS     = $(patsubst %.c,%.o,$(patsubst %.s,%.o,$(SRCS)))

# -------------------------------------
#  Targets
# -------------------------------------
all: $(TARGET).elf size

$(TARGET).elf: $(OBJS) $(LD_SCRIPT)
	$(CC) $(OBJS) $(LDFLAGS) -o $@
	@echo "Linked $@"

# Compile .c files
%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@
	@echo "Compiled: $<"

size: $(TARGET).elf
	$(SIZE) $(TARGET).elf

disasm: $(TARGET).elf
	$(OBJDUMP) -h -S $(TARGET).elf > $(TARGET).list

clean:
	$(RM) $(OBJS) $(TARGET).elf $(TARGET).map $(TARGET).list

load:
	openocd -f /usr/local/share/openocd/scripts/board/stm32f401.cfg \
		-f /usr/local/share/openocd/scripts/target/stm32f4x.cfg

.PHONY: all clean size disasm
```

---
### Cleanup Command
```make
RM := rm -rf
```

Defines a variable `RM` that holds the shell command to recursively and forcefully delete files. Used later in the `clean` target. The `:=` is an **immediate assignment** (evaluated once, right now), versus '=' which is a **lazy assignment** (evaluated every time it's used).

| Syntax   | What is does                                     |
| -------- | ------------------------------------------------ |
| `RM`     | Its a variable name                              |
| `:=`     | Immediate assignment operator                    |
| `rm -rf` | Linux command to remove files [[Linux Commands]] |

> [!question] Difference between '=' and ':='
> '=' is a lazy assignment, the value is expanded only when the variable is used later.
> ':=' is a immediate assignment, the value is expanded and stored at the moment of assignment.

---
### Tools
```make
CC      = arm-none-eabi-gcc
OBJDUMP = arm-none-eabi-objdump
SIZE    = arm-none-eabi-size
```

|Tool|Purpose|
|---|---|
|`arm-none-eabi-gcc`|Cross-compiler: compiles C code for ARM Cortex-M targets|
|`arm-none-eabi-objdump`|Disassembler: converts the ELF binary into human-readable assembly|
|`arm-none-eabi-size`|Shows the sizes of each memory section (.text, .data, .bss)|

> [!question] **Why "arm-none-eabi"?**
> - `arm` — target architecture
> - `none` — no operating system (bare metal)
> - `eabi` — Embedded Application Binary Interface (calling conventions, data layout rules)

---
### Project Name
```makefile
TARGET = SBR
```

The output filename base. All generated files will be named `SBR.*` — so you'll get `SBR.elf`, `SBR.map`, `SBR.list`.

---
### Linker Script
```makefile
LD_SCRIPT = stm32f401_ls.ld
```

The linker script tells the linker **where to place everything in memory**. For the STM32F401:

```
Flash starts at: 0x0800 0000   (up to 512KB)
SRAM starts at:  0x2000 0000   (up to 96KB)
```

Without this script, the linker wouldn't know the STM32's memory layout and would produce a broken binary.

---
### CPU Flags
```makefile
CPU_FLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
```

These tell GCC **exactly what hardware it's compiling for**.

|Flag|Meaning|
|---|---|
|`-mcpu=cortex-m4`|Target the Cortex-M4 core specifically. Enables M4-specific instructions|
|`-mthumb`|Use the Thumb-2 instruction set. Cortex-M4 **only** supports Thumb, not full ARM 32-bit|
|`-mfpu=fpv4-sp-d16`|Use the FPv4 single-precision FPU with 16 double-precision registers|
|`-mfloat-abi=hard`|Use **hardware** floating point — pass float arguments in FPU registers, not integer registers|

> [!question] **Why does `-mfloat-abi=hard` matter?** 
> With `soft`, the CPU does floating point in software (slow). With `hard`, it uses the actual FPU unit baked into the Cortex-M4 silicon (fast). The STM32F401 has an FPU, so always use `hard`.

---
### Compiler Flags
```makefile
CFLAGS = $(CPU_FLAGS) -O0 -g3 -Wall -ffunction-sections -fdata-sections
```

|Flag|Meaning|
|---|---|
|`$(CPU_FLAGS)`|Inherit all the CPU flags above|
|`-O0`|**No optimization** — easier to debug since compiler doesn't reorder/remove code|
|`-g3`|Maximum debug info — includes macro definitions, line numbers, variable info|
|`-Wall`|Enable all common warnings. Helps catch bugs early|
|`-ffunction-sections`|Place each **function** in its own ELF section (`.text.functionName`)|
|`-fdata-sections`|Place each **variable** in its own ELF section (`.data.variableName`)|

> [!question] **Why `-ffunction-sections` and `-fdata-sections`?**
>  They work together with `--gc-sections` in the linker flags. This enables **dead code elimination** — any function or variable that's never called/used gets stripped from the final binary, saving Flash space.

---
### Linker Flags
```makefile
LDFLAGS = $(CPU_FLAGS) -T$(LD_SCRIPT) -Wl,-Map=$(TARGET).map \
          -Wl,--gc-sections -static -u _printf_float \
          -Wl,--defsym=end=0
```

|Flag|Meaning|
|---|---|
|`$(CPU_FLAGS)`|The linker also needs to know the target (for correct startup code)|
|`-T$(LD_SCRIPT)`|Use `stm32f401_ls.ld` as the linker script|
|`-Wl,-Map=$(TARGET).map`|`-Wl,` passes the next argument to the **linker** (not GCC). Generates `SBR.map` — a full memory map showing where every symbol landed|
|`-Wl,--gc-sections`|**Garbage collect** unused sections (dead code removal, works with the `-ffunction-sections` flags)|
|`-static`|Don't link against shared libraries. Everything must be statically included (correct for bare metal)|
|`-u _printf_float`|Force-include the float-capable `printf` implementation. Without this, `printf("%f", ...)` would print nothing or `0.000000`|
|`-Wl,--defsym=end=0`|Defines the symbol `end` at address 0. Some C library startup code expects this symbol to exist|

---
### Source Files
```makefile
SRCS = Core/Src/main.c \
       Core/Startup/stm32f401_startup.c
```

Two source files:
- **`main.c`** — Your application code.
- **`stm32f401_startup.c`** — The startup file. This is critical. It does the following:
	1. Defines the **vector table** (interrupt vectors at `0x08000000`)
	2. Sets the **initial stack pointer**
	3. Copies `.data` from Flash to SRAM
	4. Zeros out `.bss`
	5. Calls `SystemInit()` (clock setup)
	6. Calls `main()`

Without the startup file, the MCU wouldn't know what to do after reset.

---
### Auto-Generate Object File List
```makefile
OBJS = $(patsubst %.c,%.o,$(patsubst %.s,%.o,$(SRCS)))
```

This uses Make's `patsubst` (pattern substitution) function, applied in two passes:

**Pass 1 — Handle `.s` assembly files:**

```
$(patsubst %.s,%.o,$(SRCS))
```

Replace any `filename.s` with `filename.o`

**Pass 2 — Handle `.c` C files:**

```
$(patsubst %.c,%.o, result_of_pass_1)
```

Replace any `filename.c` with `filename.o`

**Result:**

```
Core/Src/main.o
Core/Startup/stm32f401_startup.o
```

So `OBJS` automatically tracks the compiled object files corresponding to every source file.

---
### Build Targets

#### `all` — Default target
```makefile
all: $(TARGET).elf size
```

Running `make` with no arguments runs `all`. It depends on `SBR.elf` and `size` — so both get built.

---
#### Linking — producing the ELF
```makefile
$(TARGET).elf: $(OBJS) $(LD_SCRIPT)
    $(CC) $(OBJS) $(LDFLAGS) -o $@
    @echo "Linked $@"
```

**`$@`** is a Make automatic variable meaning "the target of this rule" — here it expands to `SBR.elf`.

This rule says: _"To build `SBR.elf`, I need all `.o` files and the linker script. Link them together."_

The compilation pipeline is:
```
main.c ──────────────────────────► main.o ──┐
                                             ├──► SBR.elf
stm32f401_startup.c ─────────────► startup.o ┘
```

---
#### Compiling — `.c` to `.o`
```makefile
%.o: %.c
    $(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@
    @echo "Compiled: $<"
```

This is a **pattern rule** — the `%` is a wildcard matching any stem.

|Automatic Variable|Meaning|
|---|---|
|`$<`|First prerequisite (the `.c` file)|
|`$@`|The target (the `.o` file)|

The `-c` flag tells GCC: **compile only, don't link**. Produce a `.o` object file.

---
#### `size` — Print memory usage
```makefile
size: $(TARGET).elf
    $(SIZE) $(TARGET).elf
```

Runs `arm-none-eabi-size` on the ELF. Output looks like:

```
   text    data     bss     dec     hex filename
   2048      20     512    2580     A14 SBR.elf
```

|Section|Lives in|Contains|
|---|---|---|
|`.text`|Flash|Code + const data|
|`.data`|Flash (copied to SRAM at startup)|Initialized global variables|
|`.bss`|SRAM only|Uninitialized globals (zeroed at startup)|

---
#### `disasm` — Disassemble
```makefile
disasm: $(TARGET).elf
    $(OBJDUMP) -h -S $(TARGET).elf > $(TARGET).list
```

|Flag|Meaning|
|---|---|
|`-h`|Print section headers|
|`-S`|Interleave C source with assembly|

Produces `SBR.list` — a file where you can see exactly what assembly your C compiled to. Invaluable for debugging.

---
#### `clean` — Delete build artifacts
```makefile
clean:
    $(RM) $(OBJS) $(TARGET).elf $(TARGET).map $(TARGET).list
```

Deletes all generated files, forcing a full rebuild on the next `make`.

---
#### `load` — Flash the MCU via OpenOCD
```makefile
load:
    openocd -f /usr/local/share/openocd/scripts/board/stm32f401.cfg \
            -f /usr/local/share/openocd/scripts/target/stm32f4x.cfg
```

**OpenOCD** (Open On-Chip Debugger) connects to the STM32 over SWD/JTAG and programs it. The two config files tell OpenOCD:

- The **board** layout (voltage, reset pins)
- The **target chip** (flash algorithm, memory map)

Note: This `load` target only starts OpenOCD — you'd typically also need a `-c "program SBR.elf verify reset exit"` command to actually flash the binary.

---
#### `.PHONY`
```makefile
.PHONY: all clean size disasm
```

Tells Make these are **not real files**. Without this, if a file named `clean` happened to exist in the directory, `make clean` would do nothing (thinking it's already up to date). `.PHONY` prevents that.

---
### Full Build Flow Visualized

```
make
  │
  ├─► Compile main.c ──────────────────► main.o
  │     arm-none-eabi-gcc -mcpu=cortex-m4
  │     -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
  │     -O0 -g3 -Wall -ffunction-sections
  │     -fdata-sections -c main.c -o main.o
  │
  ├─► Compile stm32f401_startup.c ─────► startup.o
  │     (same flags)
  │
  └─► Link ────────────────────────────► SBR.elf
        arm-none-eabi-gcc main.o startup.o
        -T stm32f401_ls.ld
        -Wl,--gc-sections
        -u _printf_float
        -o SBR.elf
```


---
## Metadata
Sources:
1. 

Tags: #reference #project #microcontroller 