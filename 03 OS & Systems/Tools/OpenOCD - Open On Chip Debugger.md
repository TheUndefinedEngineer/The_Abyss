*06-05-2026* 

- Aims to provide debugging, in-system programming, and boundary-scan testing for embedded target devices.
- Its free and open-source host application which allows us to program, debug, and analyze our application using GDB.
- It supports various target boards based on different processor architecture.
- It supports many types of debug adapters:
	- USB-based
	- Parallel port-based
	- other standalone boxes that run OpenOCD internally
- Flash Programming: Flash writing is supported for external CFI-compatible NOR flash and several internal flashes.

 [[Programming Adapters]]

![[overview of using debugger.png]]

## Steps to download the code using OpenOCD
1. Download and install `OpenOCD`. 
```bash
sudo apt install openocd #I don't recommend

#Instead
git clone https://github.com/openocd-org/openocd.git #clone repo
cd openocd

#install dependencies
sudo apt install usbtool libjim-dev libtool libusb-1.0-0 libusb-1.0-0-dev libjaylink-dev 

./bootstrap

#./configure --help - to check all the options
./configure --prefix=/usr/local --enable-ftdi --enable-stlink --enable-jlink #this is for STM32

make
sudo make install
```
2. Install `Telnet` client(for windows `PuTTY` software can be used) - [[]]
	- If `Telnet` application can't be used, `GDB` can be used instead. - [[GDB - GNU Debugger]]
3. Run `OpenOCD` with board configuration file.
4. Connect to the `OpenOCD` via `Telnet` client or `GDB` client.
5. Issue commands over `Telnet` or `GDB` client to `OpenOCD` to download and debug code.


---
## !
Sources:
1. [Embedded Systems Programming - 116:118](https://www.udemy.com/share/101Wdc3@GuqXF2ImTI28uNn9PdqAeG8iPZA2eo6mRPEHupgNMWRoklGN_SIy6mG0V21XVrOrMQ==/)
2. [OpenOCD Github](https://github.com/openocd-org/openocd.git)
3. [OpenOCD installation for STM32](https://youtu.be/FNDp1G0bYoU?si=R2RoZgvQvKhfwy6r)
4. 

Tags: #guide 