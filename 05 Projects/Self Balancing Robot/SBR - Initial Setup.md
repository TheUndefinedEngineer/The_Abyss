*19-04-2026* 

Tools I am installing:
- `arm-none-eabi-gcc` — the ARM cross-compiler
- `make` — build system, you write the Makefile yourself
- `OpenOCD` — flashes and debugs over ST-Link
- `GDB` (`arm-none-eabi-gdb`) — command-line debugger, connects to OpenOCD
```bash
sudo apt install neovim gcc-arm-none-eabi openocd gdb-multiarch
```

Before writing any peripheral code, I need to write:
1. **Startup file (startup.c)** - ARM assembly that runs before `main()`. It sets up the stack pointer, copies `.data` from flash to RAM, zeros `.bss`, then calls `main`. Without this, the C program has no valid memory layout and undefined behaviour starts immediately
2. **Linker script (`stm32f401.ld`)** — tells the linker where flash and RAM are, how big they are, and how to arrange your sections (`.text`, `.data`, `.bss`). Without this, the linker has no idea it's targeting an STM32.

---
## !
Sources:

Tags: