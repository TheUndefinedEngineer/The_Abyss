*18-05-2026* 
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
The terminal works as a REPL - read eval print loop.

```bash
bash -n <filename>

echo $?
```


| Syntax                |     |
| --------------------- | --- |
| `#!/usr/bin/env bash` |     |
| `echo`                |     |
| `read`                |     |
| `$1`                  |     |
| `if ...; then`        |     |
| `$@`                  |     |
| `local`               |     |
| `return`              |     |
| `sleep`               |     |
| `true`                |     |
| `false`               |     |
| `[[ .... ]]`          |     |
| `help test`           |     |
| `:`                   |     |
| echo hello \| xxd     |     |
|                       |     |

---
## Shebang

Also known as a **hashbang**, **sharp-exclamation**, or **sha-bang** is the character sequence `#!` placed at the very beginning of a script file in Unix-like operating systems. It serves as an **interpreter directive**, instructing the operating system's program loader which executable program should be used to interpret and run the rest of the file.

Syntax:
```bash
#!/bin/bash -> hardcoded

#!/usr/bin/env bash -> protable
```

> [!important] Using `#!/usr/bin/env interpreter` is often preferred over hardcoding paths (like `#!/bin/bash`) because `env` searches the system's `$PATH` for the interpreter, making the script more portable across different systems.

---
## Variables

To **create** a variable, assign a value using an equals sign with **no spaces** around it (e.g., `name=value`).  To **reference** the value, prefix the variable name with a dollar sign (e.g., `$name`).

Syntax:
```bash
# Assignment
greeting="Hello"
name="World"

# Reference and Output
echo "$greeting, $name!"

# Command Substitution
file_count=$(ls /tmp | wc -l)
echo "Files: $file_count"   
```

- **Naming**: Names must start with a letter or underscore, cannot contain spaces, and are case-sensitive.  
- **Quoting**: Use **double quotes** (`"value"`) to allow variable expansion and spaces; use **single quotes** (`'value'`) for literal strings. 
- **Command Substitution**: Capture command output by wrapping it in `$(command)` (e.g., `current_date=$(date)`). 
- **Scope**: Variables are **global** by default; use the `local` keyword inside functions to restrict scope.

---
## Parameters

### Positional Parameters

**Positional parameters** are the arguments passed to a script or function, accessed by their position: **$1**, **$2**, $3, etc. The variable $# holds the count of these parameters.

```bash
$1, $2, ... , ${10}
```

### Special Parameters

**Special parameters** are a set of predefined variables that provide information about the script or shell environment. They are not limited to command-line arguments.

| Parameter | What it does                                        |
| --------- | --------------------------------------------------- |
| `$0`      | The name of the script or shell                     |
| `$#`      | The number of positional parameters (arguments)     |
| `$*`      | All positional parameters as a single string        |
| `$?`      | The exit status of the last command executed        |
| `$$`      | The process ID (PID) of the current shell           |
| `$!`      | The process ID (PID) of the last background command |
| `$-`      | The current options set for the shell               |
| `$_`      | The last argument of the previous command           |
| `$PATH`   | The system search path for executables              |

---
## Functions

Syntax:
```bash
func() {
	local <variable name>
	# statement
	return
}
```

---
## Conditionals

### if statement

Syntax:
```bash
if [[ .... ]]; then
	# statements
else
	# statements
fi
```

### While

Syntax:
```bash
while [[ .... ]]; do
	# statements
done
```

### Until

Syntax:
```bash
until [[ .... ]]; do
	# statements
done
```

---
## For Loops

Syntax:
```bash
for <item> in <item list>: do
	#statement
done

# Example of another method
max=5
for ((i = 0; i < max; i++)); do
	echo "The number is $i"
done 
```

---
## Input & Output

### Input

Syntax:
```bash
#single
read -r foo
echo "you entered $foo"

#multiple
while read -r line; do
	echo "read line: $line"
done
```


---
## Metadata
Sources:
1. [Bash Course by YSAP](https://www.youtube.com/watch?v=Sx9zG7wa4FA)

Tags: #linux #guide #reference 