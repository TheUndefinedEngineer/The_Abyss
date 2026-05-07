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
## Starting GDB:

- gdb _name-of-executable_
- gdb -e _name-of-executable_ -c _name-of-core-file_
- gdb _name-of-executable_ --pid=_process-id_  
    Use ps -auxw to list process id's:
    Attach to a process already running:
```bash
$ ps -auxw | grep myapp
user1     2812  0.7  2.0 1009328 164768 ?      Sl Jun07   1:18 /opt/bin/myapp
$ gdb /opt/bin/myapp 2812
#OR
$ gdb /opt/bin/myapp --pid=2812
```
### Command line options

|Option|Description|
|---|---|
|--help  <br>-h|List command line arguments|
|--exec=_file-name_  <br>-e _file-name_|Identify executable associated with core file.|
|--core=_name-of-core-file_  <br>-c _name-of-core-file_|Specify core file.|
|--command=_command-file_  <br>-x _command-file_|File listing GDB commands to perform. Good for automating set-up.|
|--directory=_directory_  <br>-d _directory_|Add directory to the path to search for source files.|
|--cd=_directory_|Run GDB using specified directory as the current working directory.|
|--nx  <br>-n|Do not execute commands from ~/.gdbinit initialization file. Default is to look at this file and execute the list of commands.|
|--batch -x _command-file_|Run in batch (not interactive) mode. Execute commands from file. Requires -x option.|
|--symbols=_file-name_  <br>-s _file-name_|Read symbol table from file file.|
|--se=_file-name_|Use FILE as symbol file and executable file.|
|--write|Enable writing into executable and core files.|
|--quiet  <br>-q|Do not print the introductory and copyright messages.|
|--tty=_device_|Specify _device_ for running program's standard input and output.|
|--tui|Use a terminal user interface. Console curses based GUI interface for GDB. Generates a source and debug console area.|
|--pid=_process-id_  <br>-p _process-id_|Specify process ID number to attach to.|
|--version|Print version information and then exit.|

---
## Commands used within GDB
| Command                                                                                                                    | Description                                                                                                                                                                                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| help                                                                                                                       | List gdb command topics.                                                                                                                                                                                                                                                     |
| help _topic-classes_                                                                                                       | List gdb command within class.                                                                                                                                                                                                                                               |
| help _command_                                                                                                             | Command description.  <br>eg help show to list the show commands                                                                                                                                                                                                             |
| apropos _search-word_                                                                                                      | Search for commands and command topics containing _search-word_.                                                                                                                                                                                                             |
| info args  <br>i args                                                                                                      | List program command line arguments                                                                                                                                                                                                                                          |
| info breakpoints                                                                                                           | List breakpoints                                                                                                                                                                                                                                                             |
| info break                                                                                                                 | List breakpoint numbers.                                                                                                                                                                                                                                                     |
| info break _breakpoint-number_                                                                                             | List info about specific breakpoint.                                                                                                                                                                                                                                         |
| info watchpoints                                                                                                           | List breakpoints                                                                                                                                                                                                                                                             |
| info registers                                                                                                             | List registers in use                                                                                                                                                                                                                                                        |
| info threads                                                                                                               | List threads in use                                                                                                                                                                                                                                                          |
| info set                                                                                                                   | List set-able option                                                                                                                                                                                                                                                         |
| ***Break and Watch***                                                                                                      |                                                                                                                                                                                                                                                                              |
| break _funtion-name_  <br>break _line-number_  <br>break _ClassName::functionName_                                         | Suspend program at specified function of line number.                                                                                                                                                                                                                        |
| break +_offset_  <br>break -_offset_                                                                                       | Set a breakpoint specified number of lines forward or back from the position at which execution stopped.                                                                                                                                                                     |
| break _filename:function_                                                                                                  | Don't specify path, just the file name and function name.                                                                                                                                                                                                                    |
| break _filename:line-number_                                                                                               | Don't specify path, just the file name and line number.  <br>break _Directory/Path/filename_.cpp:62                                                                                                                                                                          |
| break *_address_                                                                                                           | Suspend processing at an instruction address. Used when you do not have source.                                                                                                                                                                                              |
| break _line-number_ if _condition_                                                                                         | Where condition is an expression. i.e. x > 5  <br>Suspend when boolean expression is true.                                                                                                                                                                                   |
| break _line_ thread _thread-number_                                                                                        | Break in thread at specified line number. Use info threads to display thread numbers.                                                                                                                                                                                        |
| tbreak                                                                                                                     | Temporary break. Break once only. Break is then removed. See "break" above for options.                                                                                                                                                                                      |
| watch _condition_                                                                                                          | Suspend processing when condition is met. i.e. x > 5                                                                                                                                                                                                                         |
| clear  <br>clear _function_  <br>clear _line-number_                                                                       | Delete breakpoints as identified by command option.  <br>Delete all breakpoints in _function_  <br>Delete breakpoints at a given line                                                                                                                                        |
| delete  <br>d                                                                                                              | Delete all breakpoints, watchpoints, or catchpoints.                                                                                                                                                                                                                         |
| delete _breakpoint-number_  <br>delete _range_                                                                             | Delete the breakpoints, watchpoints, or catchpoints of the breakpoint ranges specified as arguments.                                                                                                                                                                         |
| disable _breakpoint-number-or-range_  <br>enable _breakpoint-number-or-range_                                              | Does not delete breakpoints. Just enables/disables them.  <br>Example:  <br>Show breakpoints: info break  <br>Disable: disable 2-9                                                                                                                                           |
| enable _breakpoint-number_ once                                                                                            | Enables once                                                                                                                                                                                                                                                                 |
| continue  <br>c                                                                                                            | Continue executing until next break point/watchpoint.                                                                                                                                                                                                                        |
| continue _number_                                                                                                          | Continue but ignore current breakpoint _number_ times. Usefull for breakpoints within a loop.                                                                                                                                                                                |
| finish                                                                                                                     | Continue to end of function.                                                                                                                                                                                                                                                 |
| ***Line Execution***                                                                                                       |                                                                                                                                                                                                                                                                              |
| step  <br>s  <br>step _number-of-steps-to-perform_                                                                         | Step to next line of code. Will step into a function.                                                                                                                                                                                                                        |
| next  <br>n  <br>next _number_                                                                                             | Execute next line of code. Will not enter functions.                                                                                                                                                                                                                         |
| until  <br>until _line-number_                                                                                             | Continue processing until you reach a specified line number. Also: function name, address, filename:function or filename:line-number.                                                                                                                                        |
| info signals  <br>info handle  <br>handle _SIGNAL-NAME_ _option_                                                           | Perform the following option when signal recieved: nostop, stop, print, noprint, pass/noignore or nopass/ignore                                                                                                                                                              |
| where                                                                                                                      | Shows current line number and which function you are in.                                                                                                                                                                                                                     |
| ***Stack***                                                                                                                |                                                                                                                                                                                                                                                                              |
| backtrace  <br>bt  <br>bt _inner-function-nesting-depth_  <br>bt -_outer-function-nesting-depth_                           | Show trace of where you are currently. Which functions you are in. Prints stack backtrace.                                                                                                                                                                                   |
| backtrace full                                                                                                             | Print values of local variables.                                                                                                                                                                                                                                             |
| frame  <br>frame _number_  <br>f _number_                                                                                  | Show current stack frame (function where you are stopped)  <br>Select frame number. (can also user up/down to navigate frames)                                                                                                                                               |
| up  <br>down  <br>up _number_  <br>down _number_                                                                           | Move up a single frame (element in the call stack)  <br>Move down a single frame  <br>Move up/down the specified number of frames in the stack.                                                                                                                              |
| info frame                                                                                                                 | List address, language, address of arguments/local variables and which registers were saved in frame.                                                                                                                                                                        |
| info args  <br>info locals  <br>info catch                                                                                 | Info arguments of selected frame, local variables and exception handlers.                                                                                                                                                                                                    |
| ***Source Code***                                                                                                          |                                                                                                                                                                                                                                                                              |
| list  <br>l  <br>list _line-number_  <br>list _function_  <br>list -  <br>list _start#,end#_  <br>list _filename:function_ | List source code.                                                                                                                                                                                                                                                            |
| set listsize _count_  <br>show listsize                                                                                    | Number of lines listed when list command given.                                                                                                                                                                                                                              |
| directory _directory-name_  <br>dir _directory-name_  <br>show directories                                                 | Add specified directory to front of source code path.                                                                                                                                                                                                                        |
| directory                                                                                                                  | Clear sourcepath when nothing specified.                                                                                                                                                                                                                                     |
| ***Machine Language***                                                                                                     |                                                                                                                                                                                                                                                                              |
| info line  <br>info line _number_                                                                                          | Displays the start and end position in object code for the current line in source.  <br>Display position in object code for a specified line in source.                                                                                                                      |
| disassemble _0xstart 0xend_                                                                                                | Displays machine code for positions in object code specified (can use start and end hex memory values given by the info line command.                                                                                                                                        |
| stepi  <br>si  <br>nexti  <br>ni                                                                                           | step/next assembly/processor instruction.                                                                                                                                                                                                                                    |
| x _0xaddress_  <br>x/nfu _0xaddress_                                                                                       | Examine the contents of memory.  <br>Examine the contents of memory and specify formatting.<br><br>- n: number of display items to print<br>- f: specify the format for the output<br>- u: specify the size of the data unit (eg. byte, word, ...)<br><br>Example: x/4dw var |
| ***Examine Variables***                                                                                                    |                                                                                                                                                                                                                                                                              |
| print _variable-name_  <br>p _variable-name_  <br>p _file-name::variable-name_  <br>p '_file-name_'::_variable-name_       | Print value stored in variable.                                                                                                                                                                                                                                              |
| p *_array-variable_@_length_                                                                                               | Print first # values of array specified by _length_. Good for pointers to dynamicaly allocated memory.                                                                                                                                                                       |
| p/x _variable_                                                                                                             | Print as integer variable in hex.                                                                                                                                                                                                                                            |
| p/d _variable_                                                                                                             | Print variable as a signed integer.                                                                                                                                                                                                                                          |
| p/u _variable_                                                                                                             | Print variable as a un-signed integer.                                                                                                                                                                                                                                       |
| p/o _variable_                                                                                                             | Print variable as a octal.                                                                                                                                                                                                                                                   |
| p/t _variable_  <br>x/b _address_  <br>x/b &_variable_                                                                     | Print as integer value in binary. (1 byte/8bits)                                                                                                                                                                                                                             |
| p/c _variable_                                                                                                             | Print integer as character.                                                                                                                                                                                                                                                  |
| p/f _variable_                                                                                                             | Print variable as floating point number.                                                                                                                                                                                                                                     |
| p/a _variable_                                                                                                             | Print as a hex address.                                                                                                                                                                                                                                                      |
| x/w _address_  <br>x/4b &_variable_                                                                                        | Print binary representation of 4 bytes (1 32 bit word) of memory pointed to by address.                                                                                                                                                                                      |
| ptype _variable_  <br>ptype _data-type_                                                                                    | Prints type definition of the variable or declared variable type. Helpful for viewing class or struct definitions while debugging.                                                                                                                                           |
| ***GDB Modes***                                                                                                            |                                                                                                                                                                                                                                                                              |
| set _gdb-option_ _value_                                                                                                   | Set a GDB option                                                                                                                                                                                                                                                             |
| set logging on  <br>set logging off  <br>show logging  <br>set logging file _log-file_                                     | Turn on/off logging. Default name of file is gdb.txt                                                                                                                                                                                                                         |
| set print array on  <br>set print array off  <br>show print array                                                          | Default is off. Convient readable format for arrays turned on/off.                                                                                                                                                                                                           |
| set print array-indexes on  <br>set print array-indexes off  <br>show print array-indexes                                  | Default off. Print index of array elements.                                                                                                                                                                                                                                  |
| set print pretty on  <br>set print pretty off  <br>show print pretty                                                       | Format printing of C structures.                                                                                                                                                                                                                                             |
| set print union on  <br>set print union off  <br>show print union                                                          | Default is on. Print C unions.                                                                                                                                                                                                                                               |
| set print demangle on  <br>set print demangle off  <br>show print demangle                                                 | Default on. Controls printing of C++ names.                                                                                                                                                                                                                                  |
| ***Start and Stop***                                                                                                       |                                                                                                                                                                                                                                                                              |
| run  <br>r  <br>run _command-line-arguments_  <br>run < _infile_ > _outfile_                                               | Start program execution from the beginning of the program. The command break main will get you started. Also allows basic I/O redirection.                                                                                                                                   |
| continue  <br>c                                                                                                            | Continue execution to next break point.                                                                                                                                                                                                                                      |
| kill                                                                                                                       | Stop program execution.                                                                                                                                                                                                                                                      |
| quit  <br>q                                                                                                                | Exit GDB debugger.                                                                                                                                                                                                                                                           |

---
## GDB Operation

- Compile with the "-g" option (for most GNU and Intel compilers) which generates added information in the object code so the debugger can match a line of source code with the step of execution.
- Do not use compiler optimization directive such as "-O" or "-O2" which rearrange computing operations to gain speed as this reordering will not match the order of execution in the source code and it may be impossible to follow.
- control+c: Stop execution. It can stop program anywhere, in your source or a C library or anywhere.
- To execute a shell command: ! _command_  or shell _command_
- GDB command completion: Use TAB key info bre + TAB will complete the command resulting in info breakpoints Press TAB twice to see all available options if more than one option is available or type "M-?" + RETURN.
- GDB command abreviation: info bre + RETURN will work as bre is a valid abreviation for breakpoints








---
## !
Sources:
1. brave-ai
2. [Pkg: jimtcl](https://packages.debian.org/source/sid/jimtcl)
3. [Pkg: libjaylink-0.2](https://packages.debian.org/sid/libjaylink-dev)
4. [GDB Command Cheat Sheet](https://www.yolinux.com/TUTORIALS/GDB-Commands.html)

Tags: #guide #linux #microcontroller 