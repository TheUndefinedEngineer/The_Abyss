*24-04-2026* 

[[A Guide on Makefiles]]

```make
CC = arm-none-eabi-gcc
MACH = cortex-m4
CFLAGS = -mcpu=$(MACH) -mthumb -std=gnu11 -Wall -O0 -c

all: stm32f401_startup.o

stm32f401_startup.o:stm32f401_startup.c
	$(CC) -c $(CFLAGS) $^ -o $@
	
main.o:main.c
	$(CC) -c $(CFLAGS) $^ -o $@
	
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
## !
Sources:
1. 

Tags: #reference #project #microcontroller 