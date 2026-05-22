*06-05-2026* 
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

---
## Overviw

| Command   | Full Form                       | What it does                                                                            |
| --------- | ------------------------------- | --------------------------------------------------------------------------------------- |
| `pwd`     | print working directory         | prints the current working directory                                                    |
| `ls`      | list                            | prints list of files                                                                    |
| `touch`   | -                               | creates a file                                                                          |
| `rm`      | remove                          | delete files, directories, and symbolic links                                           |
| `clear`   | -                               | clears the terminal                                                                     |
| `cd`      | change directroy                | switch the current working directory to a specified path                                |
| `mv`      | move                            | **move** files and directories from one location to another or to **rename** them       |
| `cat`     | concatenate                     | outputs file contents in terminal                                                       |
| `grep`    | Global Regular Expression Print | scans input (files or streams) and prints all lines that match a specified text pattern |
| `echo`    | -                               | display text strings or variable values to the standard output                          |
| `less`    | -                               | pager used to view the contents of text files or command output one screen at a time    |
| `man`     | manual                          | provides access to the system's reference manual pages                                  |
| `history` |                                 |                                                                                         |
| `help`    |                                 |                                                                                         |
| `which`   |                                 |                                                                                         |
| `type`    |                                 |                                                                                         |
| `compgen` |                                 |                                                                                         |
| `file`    |                                 |                                                                                         |
| `tr`      |                                 |                                                                                         |
| `whoami`  |                                 |                                                                                         |
| `unset`   |                                 |                                                                                         |
| `uname`   |                                 |                                                                                         |
| `chmod`   |                                 |                                                                                         |
| `cp`      |                                 |                                                                                         |
| `yes`     |                                 |                                                                                         |

| Flags      | Full form        | Meaning                                  |
| ---------- | ---------------- | ---------------------------------------- |
| `<cmd> -i` | interactive flag | gives more information and conformation. |

| Variables   |     |
| ----------- | --- |
| `$PATH`     |     |
| `$PWD`      |     |
| `$USER`     |     |
| `$SHELL`    |     |
| `$MACHTYPE` |     |
| `$HOSTNAME` |     |
- lsd
- bat


---
## ls
The list command prints list of files.

Usage:
```bash
ls
ls -a
ls -l
```

| Options | Full form        | What they do                                           |
| ------- | ---------------- | ------------------------------------------------------ |
| `ls -a` | list all         | all files, even the hidden ones                        |
| `ls -l` | long list format | shows detailed information about files and directories |

---
## grep
This command scans input (files or streams) and prints all lines that match a specified text pattern.

It is derived from the **g/re/p** command found in the Unix text editor **ed**, which stands for:
- **g**: globally
- **re**: regular expression
- **p**: print

Usage:
```bash
grep [options] pattern [file...]

grep -r "pattern" /path/to/directory
grep -i "pattern" file
grep -n "pattern" file
grep -v "pattern" file
grep -c "pattern" file
grep -w "pattern" file
grep -E "pattern" file
grep -[A/B/C]<no.of lines> "pattern" file
```


| Options | Full form                   | What they do                                                   |
| ------- | --------------------------- | -------------------------------------------------------------- |
| `-r`    | Recursive search            | search through all files in a directory and its subdirectories |
| `-i`    | Case-Insensitive            | ignore uppercase/lowercase distinctions                        |
| `-n`    | Line number                 | prefix matching lines with their line numbers                  |
| `-v`    | Invert Match                | display lines that do _not_ contain the pattern                |
| `-w`    | Whole word                  | match only whole words                                         |
| `-c`    | Count Matches               | output the number of matching lines                            |
| `-E`    | Extended Regular Expression | utilize extended regex features like `+`, `?`, and `\|`        |
| `-A`    | after                       | Shows line after the matching line                             |
| `-B`    | before                      | Shows line before the matching line                            |
| `-C`    | contex                      | Shows lines both _before and after_ the match                  |
| `-o`    | only-matching               | outputs only the matching parts of a line                      |
> [!important] For complex pattern matching,
> `grep` supports regular expressions such as **`^pattern`** (start of line), **`pattern$`** (end of line), and **`.`** (any single character).


---
## echo
It is a built-in shell command used to display **text strings** or **variable values** to the standard output.

Usage:
```bash
echo [option] [string]

```


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
## Metadata
Sources:
1. [Understanding Telnet](https://youtu.be/WavoR9-wvn0?si=OAmziEl4v6xCDEOl)
2. [Basic Commands - Youtube](https://www.youtube.com/watch?v=Sx9zG7wa4FA)

Tags: #reference #linux 