*06-05-2026* 

The commands documented in this chapter here are common commands that you, as a human, may want to type and see the output of. Configuration type commands are documented elsewhere.

Intent:

- **Source Of Commands**  
    OpenOCD commands can occur in a configuration script (discussed elsewhere) or typed manually by a human or supplied programmatically, or via one of several TCP/IP Ports.
- **From the human**  
    A human should interact with the telnet interface [[Linux Commands#telnet]](default port: 4444) or via GDB [[GDB - GNU Debugger]] (default port 3333).
    
    To issue commands from within a GDB session, use the monitor command, e.g. use monitor poll to issue the poll command. All output is relayed through the GDB session.
    
- **Machine Interface** The Tcl interface’s intent is to be a machine interface. The default Tcl port is 6666.
---
## Server Commands

Command: **exit**

Exits the current telnet or Tcl session but the OpenOCD process remains running. This command should only be used in telnet or Tcl sessions (and not directly in Tcl scripts).

Note: To terminate the whole OpenOCD process, use the `shutdown` command instead.

Command: **help** _[string]_

With no parameters, prints help text for all commands. Otherwise, prints each helptext containing string. Not every command provides helptext.

Configuration commands, and commands valid at any time, are explicitly noted in parenthesis. In most cases, no such restriction is listed; this indicates commands which are only available after the configuration stage has completed.

Command: **usage** _[string]_

With no parameters, prints usage text for all commands. Otherwise, prints all usage text of which command, help text, and usage text containing string. Not every command provides helptext.

Command: **sleep** _msec [busy]_

Wait for at least msec milliseconds before resuming. If busy is passed, busy-wait instead of sleeping. (This option is strongly discouraged.) Useful in connection with script files (`script` command and `target_name` configuration).

Command: **shutdown** _[error]_

Close the OpenOCD server, disconnecting all clients (GDB, telnet, other). If option error is used, OpenOCD will return a non-zero exit code to the parent process.

If user types CTRL-C or kills OpenOCD, the command `shutdown` will be automatically executed to cause OpenOCD to exit.

It is possible to specify, in the Tcl list pre_shutdown_commands , a set of commands to be automatically executed before `shutdown` , e.g.:

lappend pre_shutdown_commands {echo "Goodbye, my friend ..."}
lappend pre_shutdown_commands {echo "see you soon !"}

The commands in the list will be executed (in the same order they occupy in the list) before OpenOCD exits. If one of the commands in the list fails, then the remaining commands are not executed anymore while OpenOCD will proceed to quit.

Command: **debug_level** _[number]_

Without arguments it displays the current debug level. If number (from 0..4) is provided, then set it to that level. This affects the kind of messages sent to the server log. Level 0 is error messages only; level 1 adds warnings; level 2 adds informational messages; level 3 adds debugging messages; level 4 adds verbose low-level debug messages; and level 5 adds USB communication messages and amount of free heap space if mallinfo is available. The default is level 2, but that can be overridden on the command line along with the location of that log file (which is normally the server’s standard output). See [Running](https://openocd.org/doc/html/Running.html).

Command: **echo** _[-n] message_

Logs a message at "user" priority. Option "-n" suppresses trailing newline.

echo "Downloading kernel -- please wait"

Command: **log_output** _[filename | 'default']_

Redirect logging to filename. If used without an argument or filename is set to ’default’ log output channel is set to stderr.

Command: **add_script_search_dir** _directory_

Add directory to the file/script search path.

Config Command: **bindto** _[name]_

Specify hostname or IPv4 address on which to listen for incoming TCP/IP connections. By default, OpenOCD will listen on the loopback interface only. If your network environment is safe, `bindto 0.0.0.0` can be used to cover all available interfaces.

---
## Target State handling

In this section “target” refers to a CPU configured as shown earlier (see [CPU Configuration](https://openocd.org/doc/html/CPU-Configuration.html)). These commands, like many, implicitly refer to a current target which is used to perform the various operations. The current target may be changed by using `targets` command with the name of the target which should become current.

Command: **reg** _[(number|name) [(value|'force')]]_

Access a single register by number or by its name. The target must generally be halted before access to CPU core registers is allowed. Depending on the hardware, some other registers may be accessible while the target is running.

_With no arguments_: list all available registers for the current target, showing number, name, size, value, and cache status. For valid entries, a value is shown; valid entries which are also dirty (and will be written back later) are flagged as such.

_With number/name_: display that register’s value. Use force argument to read directly from the target, bypassing any internal cache.

_With both number/name and value_: set register’s value. Writes may be held in a writeback cache internal to OpenOCD, so that setting the value marks the register as dirty instead of immediately flushing that value. Resuming CPU execution (including by single stepping) or otherwise activating the relevant module will flush such values.

Cores may have surprisingly many registers in their Debug and trace infrastructure:

```
 reg
===== ARM registers
(0) r0 (/32): 0x0000D3C2 (dirty)
(1) r1 (/32): 0xFD61F31C
(2) r2 (/32)
...
(164) ETM_contextid_comparator_mask (/32)
```

Command: **set_reg** _dict_

Set register values of the target.

- dict ... Tcl dictionary with pairs of register names and values.

For example, the following command sets the value 0 to the program counter (pc) register and 0x1000 to the stack pointer (sp) register:

set_reg {pc 0 sp 0x1000}

Command: **get_reg** _[-force] list_

Get register values from the target and return them as Tcl dictionary with pairs of register names and values. If option "-force" is set, the register values are read directly from the target, bypassing any caching.

- list ... List of register names

For example, the following command retrieves the values from the program counter (pc) and stack pointer (sp) register:

get_reg {pc sp}

Command: **write_memory** _address width data ['phys']_

This function provides an efficient way to write to the target memory from a Tcl script.

- address ... target memory address
- width ... memory access bit size, can be 8, 16, 32 or 64
- data ... Tcl list with the elements to write
- [’phys’] ... treat the memory address as physical instead of virtual address

For example, the following command writes two 32 bit words into the target memory at address 0x20000000:

write_memory 0x20000000 32 {0xdeadbeef 0x00230500}

Command: **read_memory** _address width count ['phys']_

This function provides an efficient way to read the target memory from a Tcl script. A Tcl list containing the requested memory elements is returned by this function.

- address ... target memory address
- width ... memory access bit size, can be 8, 16, 32 or 64
- count ... number of elements to read
- [’phys’] ... treat the memory address as physical instead of virtual address

For example, the following command reads two 32 bit words from the target memory at address 0x20000000:

read_memory 0x20000000 32 2

Command: **debug_reason**

Displays the current debug reason: `debug-request`, `breakpoint`, `watchpoint`, `watchpoint-and-breakpoint`, `single-step`, `target-not-halted`, `program-exit`, `exception-catch` or `undefined`.

Command: **halt** _[ms]_

Command: **wait_halt** _[ms]_

The `halt` command first sends a halt request to the target, which `wait_halt` doesn’t. Otherwise these behave the same: wait up to ms milliseconds, or 5 seconds if there is no parameter, for the target to halt (and enter debug mode). Using 0 as the ms parameter prevents OpenOCD from waiting.

> [!warning] 
> On ARM cores, software using the _wait for interrupt_ operation often blocks the JTAG access needed by a `halt` command. This is because that operation also puts the core into a low power mode by gating the core clock; but the core clock is needed to detect JTAG clock transitions.
> 
> One partial workaround uses adaptive clocking: when the core is interrupted the operation completes, then JTAG clocks are accepted at least until the interrupt handler completes. However, this workaround is often unusable since the processor, board, and JTAG adapter must all support adaptive JTAG clocking. Also, it can’t work until an interrupt is issued.
> 
> A more complete workaround is to not use that operation while you work with a JTAG debugger. Tasking environments generally have idle loops where the body is the _wait for interrupt_ operation. (On older cores, it is a coprocessor action; newer cores have a wfi instruction.) Such loops can just remove that operation, at the cost of higher power consumption (because the CPU is needlessly clocked).

Command: **resume** _[address]_

Resume the target at its current code position, or the optional address if it is provided.

**NOTE:** targets are expected to temporary disable breakpoints if they match the address of the current code position or the address provided by user.

Command: **step** _[address]_

Single-step the target at its current code position, or the optional address if it is provided.

**NOTE:** targets are expected to temporary disable breakpoints if they match the address of the current code position or the address provided by user.

Command: **reset**

Command: **reset run**

Command: **reset halt**

Command: **reset init**

Perform as hard a reset as possible, using SRST if possible. _All defined targets will be reset, and target events will fire during the reset sequence._

The optional parameter specifies what should happen after the reset. If there is no parameter, a `reset run` is executed. The other options will not work on all systems. See [Reset Configuration](https://openocd.org/doc/html/Reset-Configuration.html).

- - **run** Let the target run
- - **halt** Immediately halt the target
- - **init** Immediately halt the target, and execute the reset-init script

Command: **soft_reset_halt**

Requesting target halt and executing a soft reset. This is often used when a target cannot be reset and halted. The target, after reset is released begins to execute code. OpenOCD attempts to stop the CPU and then sets the program counter back to the reset vector. Unfortunately the code that was executed may have left the hardware in an unknown state.

Command: **adapter assert** _[signal [assert|deassert signal]]_

Command: **adapter deassert** _[signal [assert|deassert signal]]_

Set values of reset signals. Without parameters returns current status of the signals. The signal parameter values may be srst, indicating that srst signal is to be asserted or deasserted, trst, indicating that trst signal is to be asserted or deasserted.

The `reset_config` command should already have been used to configure how the board and the adapter treat these two signals, and to say if either signal is even present. See [Reset Configuration](https://openocd.org/doc/html/Reset-Configuration.html). Trying to assert a signal that is not present triggers an error. If a signal is present on the adapter and not specified in the command, the signal will not be modified.

> [!note] Note: 
> TRST is specially handled. It actually signifies JTAG’s RESET state. So if the board doesn’t support the optional TRST signal, or it doesn’t support it along with the specified SRST value, JTAG reset is triggered with TMS and TCK signals instead of the TRST signal. And no matter how that JTAG reset is triggered, once the scan chain enters RESET with TRST inactive, TAP `post-reset` events are delivered to all TAPs with handlers for that event.

---
## Memory access commands

These commands allow accesses of a specific size to the memory system. Often these are used to configure the current target in some special way. For example - one may need to write certain values to the SDRAM controller to enable SDRAM.

1. Use the `targets` (plural) command to change the current target.
2. In system level scripts these commands are deprecated. Please use their TARGET object siblings to avoid making assumptions about what TAP is the current target, or about MMU configuration.

Command: **mdd** _[phys] addr [count]_

Command: **mdw** _[phys] addr [count]_

Command: **mdh** _[phys] addr [count]_

Command: **mdb** _[phys] addr [count]_

Display contents of address addr, as 64-bit doublewords (`mdd`), 32-bit words (`mdw`), 16-bit halfwords (`mdh`), or 8-bit bytes (`mdb`). When the current target has an MMU which is present and active, addr is interpreted as a virtual address. Otherwise, or if the optional phys flag is specified, addr is interpreted as a physical address. If count is specified, displays that many units. (If you want to process the data instead of displaying it, see the `read_memory` primitives.)

Command: **mwd** _[phys] addr doubleword [count]_

Command: **mww** _[phys] addr word [count]_

Command: **mwh** _[phys] addr halfword [count]_

Command: **mwb** _[phys] addr byte [count]_

Writes the specified doubleword (64 bits), word (32 bits), halfword (16 bits), or byte (8-bit) value, at the specified address addr. When the current target has an MMU which is present and active, addr is interpreted as a virtual address. Otherwise, or if the optional phys flag is specified, addr is interpreted as a physical address. If count is specified, fills that many units of consecutive address.

---
## Image loading commands

Command: **dump_image** _filename address size_

Dump size bytes of target memory starting at address to the binary file named filename.

Command: **fast_load**

Loads an image stored in memory by `fast_load_image` to the current target. Must be preceded by fast_load_image.

Command: **fast_load_image** _filename [address [bin|ihex|elf|s19 [min_addr [max_length]]]]_

Normally you should be using `load_image` or GDB load. However, for testing purposes or when I/O overhead is significant(OpenOCD running on an embedded host), storing the image in memory and uploading the image to the target can be a way to upload e.g. multiple debug sessions when the binary does not change. Arguments are the same as `load_image`, but the image is stored in OpenOCD host memory, i.e. does not affect target. This approach is also useful when profiling target programming performance as I/O and target programming can easily be profiled separately.

Command: **load_image** _filename [address [bin|ihex|elf|s19 [min_addr [max_length]]]]_

Load image from file filename to target memory. If an address is specified, it is used as an offset to the file format defined addressing (e.g. bin file is loaded at that address). The file format may optionally be specified (bin, ihex, elf, or s19). In addition the following arguments may be specified: min_addr - ignore data below min_addr (this is w.r.t. to the target’s load address + address) max_length - maximum number of bytes to load.

proc load_image_bin {fname foffset address length } {
    # Load data from fname filename at foffset offset to
    # target at address. Load at most length bytes.
    `load_image $fname [expr {$address - $foffset}] bin \
	    `$address $length`
}

Command: **test_image** _filename [address [bin|ihex|elf]]_

Displays image section sizes and addresses as if filename were loaded into target memory starting at address (defaults to zero). The file format may optionally be specified (bin, ihex, or elf)

Command: **verify_image** _filename [address [bin|ihex|elf]]_

Verify filename against target memory. If an address is specified, it is used as an offset to the file format defined addressing (e.g. bin file is compared against memory starting at that address). The file format may optionally be specified (bin, ihex, or elf) This will first attempt a comparison using a CRC checksum, if this fails it will try a binary compare.

Command: **verify_image_checksum** _filename [address [bin|ihex|elf]]_

Verify filename against target memory. If an address is specified, it is used as an offset to the file format defined addressing (e.g. bin file is compared against memory starting at that address). The file format may optionally be specified (bin, ihex, or elf) This perform a comparison using a CRC checksum only

---
## Breakpoint and Watchpoint commands

CPUs often make debug modules accessible through JTAG, with hardware support for a handful of code breakpoints and data watchpoints. In addition, CPUs almost always support software breakpoints.

Command: **bp** _[address [asid] len [hw | hw_ctx]]_

With no parameters, lists all active breakpoints. Else sets a breakpoint on code execution starting at address for length bytes. This is a software breakpoint, unless hw or hw_ctx is specified in which case it will be a hardware, context or hybrid breakpoint. The context and hybrid breakpoints require an additional parameter asid: address space identifier.

(See [arm9 vector_catch](https://openocd.org/doc/html/Architecture-and-Core-Commands.html#arm9vectorcatch), or see [xscale vector_catch](https://openocd.org/doc/html/Architecture-and-Core-Commands.html#xscalevectorcatch), for similar mechanisms that do not consume hardware breakpoints.)

Command: **rbp** _all | address_

Remove the breakpoint at address or all breakpoints.

Command: **rwp** _all | address_

Remove data watchpoint on address or all watchpoints.

Command: **wp** _[address length [(r|w|a) [value [mask]]]]_

With no parameters, lists all active watchpoints. Else sets a data watchpoint on data from address for length bytes. The watch point is an "access" watchpoint unless the r or w parameter is provided, defining it as respectively a read or write watchpoint. If a value is provided, that value is used when determining if the watchpoint should trigger. The value may be first be masked using mask to mark “don’t care” fields.

---
## Real Time Transfer (RTT)

Real Time Transfer (RTT) is an interface specified by SEGGER based on basic memory reads and writes to transfer data bidirectionally between target and host. The specification is independent of the target architecture. Every target that supports so called "background memory access", which means that the target memory can be accessed by the debugger while the target is running, can be used. This interface is especially of interest for targets without Serial Wire Output (SWO), such as ARM Cortex-M0, or where semihosting is not applicable because of real-time constraints.

> [!note] **Note:** The current implementation supports only single target devices.

The data transfer between host and target device is organized through unidirectional up/down-channels for target-to-host and host-to-target communication, respectively.

> [!note] **Note:** The current implementation does not respect channel buffer flags. They are used to determine what happens when writing to a full buffer, for example.

Channels are exposed via raw TCP/IP connections. One or more RTT servers can be assigned to each channel to make them accessible to an unlimited number of TCP/IP connections.

Command: **rtt setup** _address size [ID]_

Configure RTT for the currently selected target. Once RTT is started, OpenOCD searches for a control block with the identifier ID starting at the memory address address within the next size bytes. ID defaults to the string "SEGGER RTT"

Command: **rtt start**

Start RTT. If the control block location is not known, OpenOCD starts searching for it.

Command: **rtt stop**

Stop RTT.

Command: **rtt polling_interval** _[interval]_

Display the polling interval. If interval is provided, set the polling interval. The polling interval determines (in milliseconds) how often the up-channels are checked for new data.

Command: **rtt channels**

Display a list of all channels and their properties.

Command: **rtt channellist**

Return a list of all channels and their properties as Tcl list. The list can be manipulated easily from within scripts.

Command: **rtt server start** _port channel [message]_

Start a TCP server on port for the channel channel. When message is not empty, it will be sent to a client when it connects.

Command: **rtt server stop** _port_

Stop the TCP sever with port port.

The following example shows how to setup RTT using the SEGGER RTT implementation on the target device.

resume

rtt setup 0x20000000 2048
rtt start

rtt server start 9090 0

In this example, OpenOCD searches the control block with the ID "SEGGER RTT" starting at 0x20000000 for 2048 bytes. The RTT channel 0 is exposed through the TCP/IP port 9090.

---
## Misc Commands

Command: **profile** _seconds filename [start end]_

Profiling samples the CPU’s program counter as quickly as possible, which is useful for non-intrusive stochastic profiling. Saves up to 1000000 samples in filename using “gmon.out” format. Optional start and end parameters allow to limit the address range.

Command: **version** _[git]_

Returns a string identifying the version of this OpenOCD server. With option git, it returns the git version obtained at compile time through “git describe”.

Command: **virt2phys** _virtual_address_

Requests the current target to map the specified virtual_address to its corresponding physical address, and displays the result.

Command: **add_help_text** _command_name help_string_

Add or replace help text on the given command_name.

Command: **add_usage_text** _command_name help_string_

Add or replace usage text on the given command_name.

Command: **ms**

Returns current time since the Epoch in ms



---
## !
Sources:
1. [OpenOCD General Commands](https://openocd.org/doc/html/General-Commands.html)
2. 

Tags: #reference 