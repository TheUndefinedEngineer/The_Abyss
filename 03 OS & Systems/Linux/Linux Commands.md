*06-05-2026* 

---
## info
1. `info` is a documentation system and viewer developed by the GNU Project, primarily used for reading manuals written in the Texinfo format.
   
2.  It is the standard way to access online documentation for most GNU software, including tools like GCC, [[GDB - GNU Debugger]], and [[OpenOCD - Open On Chip Debugger]].
   
3. Installation:
```bash
#debian
sudo apt install info
```

4. Usage:
	 - **`info`**: Running the command without arguments opens the top-level Info directory menu. 
	- **`info <command>`**: Opens the Info manual for a specific command or topic (e.g., `info ls`, `info gcc`). 
	- **`info --apropos=<STRING>`**: Searches the indices of all manuals for a keyword (e.g., `info --apropos="network"`).
```bash
info [OPTIONS] [MENU-ITEM]

#example
info openocd   
```

5. **Navigation Commands:** Key commands include:
    - `n` / `p` / `u`: Go to the Next, Previous, or Up node.
    - `m`: Select a menu item (e.g., `m Top RET`).
    - `g`: Go to a specific node by name (e.g., `g Index RET`).
    - `s`: Search for text within the current document.
    - `i`: Search the document's index.
    - `q`: Quit the Info reader.
---
## telnet

1. It is a command line tool used to connect to remote systems using the `Telnet` protocol. It allows us to connect to remote systems over internet and perform various tasks, such as sending email, transferring files, and running remote commands.

2. Installation:
```bash
#debian
sudo apt install telnet
```

3. Usage:
```bash
telnet [OPTION...] [HOST [PORT]]

#example
telnet localhost 4444
telnet google.com 80
```

4. Troubleshooting:
```bash
# 1 
> telnet google.com 1443  
> Trying 2404:6800:4009:809::200e...
# If its only showing connecting then most probably the port number is wrong for that region.

# 2
> telnet --help
# Use --help flag to get more information on options.
```

5. Used in - [[OpenOCD - Open On Chip Debugger]]


---
## !
Sources:
1. [Understanding Telnet](https://youtu.be/WavoR9-wvn0?si=OAmziEl4v6xCDEOl)

Tags: #reference #linux 