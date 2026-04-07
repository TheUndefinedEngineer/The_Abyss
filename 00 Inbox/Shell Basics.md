---

---
 04/02/2026
# What is a Shell?

1. Show prompt
2. Read user input
3. Understand the command
4. Create a process
5. Run the command
6. Wait (or not)
7. Repeat

# Architecture

```bash
┌──────────┐
│  Prompt  │
└────┬─────┘
     ↓
┌──────────┐
│  Parser  │  ← splits command & arguments
└────┬─────┘
     ↓
┌──────────┐
│ Executor │  ← fork + exec
└──────────┘
```

## The Shell Loop(Heart of the Program)
```c
while(1){
	print_promt();
	read_command();
	prase_command();
	execute_command();
}
```
- This is what every shell basically does.
- If I understand this loop deeply, I understand bash, zsh, busybox sh.

## What is a Prompt?

It is just like a `printf()` function, later I can add:
	- current directory
	- username
	- colors

## Reading Input

- The input can be read as a **full line** only, not just a word.
- There are 2 common choices:
	- `fgets()` - simple and safe
	- `getline()` - dynamic

## Parse the Command

- The shell doesn't understand english rather it understands **tokens**.
- Example:
```bash
ls -l /home
```
	Prased as:
```cpp
argv[0] = "ls"
argv[1] = "-l"
argv[2] = "/home"
argv[3] = NULLL
```


## fork(): Creating a New Process

Why fork?

Because **your shell must stay alive**.
```bash
Parent (shell)
   |
   +--> Child (runs ls)
```
- Parent → waits
- Child → executes command

## exec(): Replace Child Process

Child does:
```c
execvp("ls", argv);
```
If `exec` succeeds:
- Child becomes `ls`.
- The code is gone.
- Linux loads `/bin/ls`.
If it fails:
- Print error.
- Exit child.

## wait(): Synchronization

Parent waits for child:
```c
wait(NULL);
```
This is why shell waits until `ls` finishes.
Later:
- `&` -> no wait
- background jobs

## ## One Very Important Concept (Exam + Interview)

- **fork() duplicates the process**  
- **exec() replaces the process**

# Minimal Working Flow

When a user types:
```bash
ls
```
What actually happens is:
```scss
mini-shell
 ├─ fork()
 │   ├─ child → exec(ls)
 │   └─ parent → wait()
```

