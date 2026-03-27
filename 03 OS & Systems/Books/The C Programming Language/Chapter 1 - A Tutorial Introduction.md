## Section 1.1
- A `C` program file uses `.c` extension and complied using `gcc`.
- It generates a `a.out` file.
- Every C program has a main function which accepts no arguments.
- Has header files at the top of the program.
- The main function uses other functions be it user defined or library functions to help perform its job.
- Then there are are variables & escape characters.

```bash
nano hello_world.c
```

```c
#include <stdio.h>

int main(){
	printf("Hello World!\n);
}
```

```bash
gcc hello_world.c
./a.out
```
- We can use either `cc` or directly use `gcc` to compile.
## Section 1.2
- Variables - store values which can be modified
- Declared before being used:
```c
int value, name;
float pi = 3.14;
```
- There are different types of data types available and are of different sizes depending of the machine:
	- char - Character - a single byte
	- short - short integer
	- long - long integer
	- double - double- precision floating point
	- arrays
	- structures
	- unions
- 