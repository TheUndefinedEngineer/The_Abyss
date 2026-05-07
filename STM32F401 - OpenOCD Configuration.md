*07-05-2026* 

## Installation:
```bash
#install dependencies
sudo apt install usbtool libjim-dev libtool libusb-1.0-0 libusb-1.0-0-dev libjaylink-dev 

git clone https://github.com/openocd-org/openocd.git #clone repo
cd openocd

./bootstrap

#./configure --help - to check all the options
./configure --prefix=/usr/local --enable-ftdi --enable-stlink --enable-jlink 

make
sudo make install
```

---
## Setup:
```bash
cd /usr/local/share/openocd/scripts/
```

There is no board script for stm32f401 so I created my own:
1. Create a new file in `/boards`
```bash
nvim stm32f401.cfg
```
2. Using the general config of `stlink.cfg` which is present in `/interface`. I sourced it into `/boards/stm32f401.cfg`
```tcl
# stm32f401.cfg  
  
source [find interface/stlink.cfg]   # find searches OpenOCD's script directories for the file source — loads and executes that file.
  
transport select swd                 # tells OpenOCD to use SWD protocol.
  
adapter speed 2000                   # sets communication speed to 2000 kHz (2 MHz) between ST-Link and STM32.
```
> [!important] OpenOCD uses a `Tcl` interpreter internally for all its configuration and command scripting. That's also why in telnet we just type commands directly

---
## Usage:
In Makefile add the `openocd -f` command.
```make
load:
	openocd -f /usr/local/share/openocd/scripts/board/stm32f401.cfg  \
			-f /usr/local/share/openocd/scripts/target/stm32f4x.cfg

```

Running `fmake load` will connect `ST-LINK V2` to `STM32F401` boards.


---
## !
Sources:
1. [OpenOCD installation for STM32](https://youtu.be/FNDp1G0bYoU?si=R2RoZgvQvKhfwy6r) - Installation and how to use the scripts.
2. Claude helped with the rest.

Tags: #guide #microcontroller 