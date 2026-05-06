*06-05-2026* 

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
## !
Sources:
1. 

Tags: #reference #linux 