04/02/2026

*Obviously need a linux system* - I am using debian with i3wm

Code editor I chose - vs code, because It just works.

Need to install Complier - `GCC, make`
```bash
sudo apt isntall build-essential
```
![[Pasted image 20260204192913.png]]

Debugger - `GDB`
```bash
sudo apt install gdb
```
![[Pasted image 20260204193654.png]]

Of course version control - `git`
```bash
sudo apt install git
```
![[Pasted image 20260204193921.png]]

Verification:
![[Pasted image 20260204194123.png]]

### Folder Setup
```bash
mini-linux-shell/
├── src/
│   └── main.c
├── README.md
├── Makefile
└── .git/

```


## strcspn() Function Overview

The `strcspn()` function is a standard C library function used to calculate the length of the initial segment of a string that **does not contain any characters from a specified set**.  It is commonly used for string parsing and validation tasks. 

It is declared in the `<string.h>` header file and has the following syntax:

```
size_t strcspn(const char *str1, const char *str2);
```

- `str1`: The target string to be scanned.
    
- `str2`: A string containing the set of characters to avoid.
    
- Returns the number of characters in `str1` before the first occurrence of any character from `str2`. 
    

If no characters from `str2` are found in `str1`, the function returns the full length of `str1`

