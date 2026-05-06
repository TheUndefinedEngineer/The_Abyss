*06-05-2026* 
## Introduction

**GDB** stands for **GNU Debugger**, a powerful, open-source debugging tool developed by the GNU Project

### gdb vs gdb-multiarch

- **`gdb`**: Installs the standard debugger for the host architecture (typically x86_64). 

- **`gdb-multiarch`**: Installs a version of GDB capable of debugging binaries for various architectures (ARM, AArch64, RISC-V, etc.).

> [!question] What is gdb-arm-none-eabi?
> `gdb-arm-none-eabi` is a version of the GNU Debugger specifically configured for **bare-metal ARM** targets, such as microcontrollers (e.g., Cortex-M, Cortex-R, Cortex-A without an OS).  It allows for source-level debugging of embedded firmware using debug probes like J-Link or ST-Link, typically in conjunction with a server like OpenOCD. 
> 
> It is part of the `arm-none-eabi` toolchain, where the prefix denotes:
> - **arm**: The target architecture. 
> - **none**: No operating system (bare metal). 
> - **eabi**: The Embedded Application Binary Interface.

On modern Linux distributions, `gdb-multiarch` is often preferred as it supports debugging multiple architectures, including ARM. Many users create a symlink from `arm-none-eabi-gdb` to `gdb-multiarch` to satisfy project requirements that expect the specific ARM binary name.****

---
## Installation

```bash
sudo apt update && sudo apt upgrade -y

#Method 1
sudo apt install gdb-arm-none-eabi   

#Method 2 - Recommended
sudo apt install gdb-multiarch 
```

## Creating symbolic link

```bash
sudo ln -s /usr/bin/gdb-multiarch /usr/bin/arm-none-eabi-gdb   
```

## Troubleshooting Missing Libraries

```bash
sudo apt install libncurses5   
```

---
## !
Sources:
1. brave-ai
2. [Pkg: jimtcl](https://packages.debian.org/source/sid/jimtcl)
3. [Pkg: libjaylink-0.2](https://packages.debian.org/sid/libjaylink-dev)
4. 

Tags: #guide #linux #microcontroller 