*22-04-2026* 

Makefiles are used to help decide which parts of a large program need to be recompiled. In the vast majority of cases, C or C++ files are compiled. Other languages typically have their own tools that serve a similar purpose as `Make`. `Make` can also be used beyond compilation too, when you need a series of instructions to run depending on what files have changed.

![[makefile-example.png|631]]

## Alternatives of Make
- Popular ones for C/C++:
	- SCons
	- CMake
	- Bazel
	- Ninja
- For Java:
	- Ant
	- Maven
	- Gradle
- Other languages like Go, Rust, and Typescript have their own build tools.

Interpreted languages like Python, Ruby, and raw Javascript don't require an analogue to Makefiles.

## Makefile Syntax
A Makefile consists of a set of _rules_. A rule generally looks like this:
```make
targets: prerequisites 
	command 
	command 
	command
```
- The _targets_ are file names, separated by spaces. Typically, there is only one per rule.
- The _commands_ are a series of steps typically used to make the target(s). These _need to start with a tab character_, not spaces.
- The _prerequisites_ are also file names, separated by spaces. These files need to exist before the commands for the target are run. These are also called _dependencies_
---
## Make clean

`clean` is often used as a target that removes the output of other targets, but it is not a special word in Make. You can run `make` and `make clean` on this to create and delete `some_file`.

Note that `clean` is doing two new things here:

- It's a target that is not first (the default), and not a prerequisite. That means it'll never run unless you explicitly call `make clean`
- It's not intended to be a filename. If you happen to have a file named `clean`, this target won't run, which is not what we want. See `.PHONY` later in this tutorial on how to fix this

```
some_file: 
	touch some_file

clean:
	rm -f some_file
```

---
## Variables

Variables can only be strings. You'll typically want to use `:=`, but '=' also works.

Example:
```
files := file1 file2
some_file: $(files)
	echo "Look at this variable: " $(files)
	touch some_file

file1:
	touch file1
file2:
	touch file2

clean:
	rm -f file1 file2 some_file
```

Single or double quotes have no meaning to Make. They are simply characters that are assigned to the variable. Quotes _are_ useful to shell/bash, though, and you need them in commands like `printf`. In this example, the two commands behave the same:

```
a := one two# a is set to the string "one two"
b := 'one two' # Not recommended. b is set to the string "'one two'"
all:
	printf '$a'
	printf $b
```

Reference variables using either `${}` or `$()`

```
x := dude

all:
	echo $(x)
	echo ${x}

	# Bad practice, but works
	echo $x 
```

---
## Targets

### The all target

Making multiple targets and you want all of them to run? Make an `all` target. Since this is the first rule listed, it will run by default if `make` is called without specifying a target.

```
all: one two three

one:
	touch one
two:
	touch two
three:
	touch three

clean:
	rm -f one two three
```

### Multiple targets

When there are multiple targets for a rule, the commands will be run for each target. `$@` is an [automatic variable](https://makefiletutorial.com/#automatic-variables) that contains the target name.

```
all: f1.o f2.o

f1.o f2.o:
	echo $@
# Equivalent to:
# f1.o:
#	 echo f1.o
# f2.o:
#	 echo f2.o
```

---
## Automatic Variables and Wildcards
### * Wildcard

Both `*` and `%` are called wildcards in Make, but they mean entirely different things. `*` searches the file system for matching filenames. It is recommended to always wrap it in the `wildcard` function, because otherwise you may fall into a common pitfall described below.

```
# Print out file information about every .c file
print: $(wildcard *.c)
	ls -la  $?
```

`*` may be used in the target, prerequisites, or in the `wildcard` function.

> [!danger] `*` may not be directly used in a variable definitions

> [!danger] When `*` matches no files, it is left as it is (unless run in the `wildcard` function)

```
thing_wrong := *.o # Don't do this! '*' will not get expanded
thing_right := $(wildcard *.o)

all: one two three four

# Fails, because $(thing_wrong) is the string "*.o"
one: $(thing_wrong)

# Stays as *.o if there are no files that match this pattern :(
two: *.o 

# Works as you would expect! In this case, it does nothing.
three: $(thing_right)

# Same as rule three
four: $(wildcard *.o)
```

### % Wildcard

`%` is really useful, but is somewhat confusing because of the variety of situations it can be used in.

- When used in "matching" mode, it matches one or more characters in a string. This match is called the stem.
- When used in "replacing" mode, it takes the stem that was matched and replaces that in a string.
- `%` is most often used in rule definitions and in some specific functions.

### Automatic Variables

There are many automatic variables, but often only a few show up:

```
hey: one two
	# Outputs "hey", since this is the target name
	echo $@

	# Outputs all prerequisites newer than the target
	echo $?

	# Outputs all prerequisites
	echo $^

	# Outputs the first prerequisite
	echo $<

	touch hey

one:
	touch one

two:
	touch two

clean:
	rm -f hey one two
```

---
## Implicit Rules

- Compiling a C program: `n.o` is made automatically from `n.c` with a command of the form `$(CC) -c $(CPPFLAGS) $(CFLAGS) $^ -o $@`
- Compiling a C++ program: `n.o` is made automatically from `n.cc` or `n.cpp` with a command of the form `$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $^ -o $@`
- Linking a single object file: `n` is made automatically from `n.o` by running the command `$(CC) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@`

The important variables used by implicit rules are:

- `CC`: Program for compiling C programs; default `cc`
- `CXX`: Program for compiling C++ programs; default `g++`
- `CFLAGS`: Extra flags to give to the C compiler
- `CXXFLAGS`: Extra flags to give to the C++ compiler
- `CPPFLAGS`: Extra flags to give to the C pre-processor
- `LDFLAGS`: Extra flags to give to compilers when they are supposed to invoke the linker

```
CC = gcc # Flag for implicit rules
CFLAGS = -g # Flag for implicit rules. Turn on debug info

# Implicit rule #1: blah is built via the C linker implicit rule
# Implicit rule #2: blah.o is built via the C compilation implicit rule, because blah.c exists
blah: blah.o

blah.c:
	echo "int main() { return 0; }" > blah.c

clean:
	rm -f blah*
```

---
## Static Pattern Rules

Static pattern rules are another way to write less in a Makefile. syntax:
```
targets...: target-pattern: prereq-patterns ...
   commands
```

The essence is that the given `target` is matched by the `target-pattern` (via a `%` wildcard). Whatever was matched is called the _stem_. The stem is then substituted into the `prereq-pattern`, to generate the target's prereqs.

A typical use case is to compile `.c` files into `.o` files. Here's the _manual way_:

```
objects = foo.o bar.o all.o
all: $(objects)
	$(CC) $^ -o all

foo.o: foo.c
	$(CC) -c foo.c -o foo.o

bar.o: bar.c
	$(CC) -c bar.c -o bar.o

all.o: all.c
	$(CC) -c all.c -o all.o

all.c:
	echo "int main() { return 0; }" > all.c

# Note: all.c does not use this rule because Make prioritizes more specific matches when there is more than one match.
%.c:
	touch $@

clean:
	rm -f *.c *.o all
```

Here's the more _efficient way_, using a static pattern rule:
```
objects = foo.o bar.o all.o
all: $(objects)
	$(CC) $^ -o all

# Syntax - targets ...: target-pattern: prereq-patterns ...
# In the case of the first target, foo.o, the target-pattern matches foo.o and sets the "stem" to be "foo".
# It then replaces the '%' in prereq-patterns with that stem
$(objects): %.o: %.c
	$(CC) -c $^ -o $@

all.c:
	echo "int main() { return 0; }" > all.c

# Note: all.c does not use this rule because Make prioritizes more specific matches when there is more than one match.
%.c:
	touch $@

clean:
	rm -f *.c *.o all
```

## Static Pattern Rules and Filter

The `filter` function can be used in Static pattern rules to match the correct files. In this example, I made up the `.raw` and `.result` extensions.

```
obj_files = foo.result bar.o lose.o
src_files = foo.raw bar.c lose.c

all: $(obj_files)
# Note: PHONY is important here. Without it, implicit rules will try to build the executable "all", since the prereqs are ".o" files.
.PHONY: all 

# Ex 1: .o files depend on .c files. Though we don't actually make the .o file.
$(filter %.o,$(obj_files)): %.o: %.c
	echo "target: $@ prereq: $<"

# Ex 2: .result files depend on .raw files. Though we don't actually make the .result file.
$(filter %.result,$(obj_files)): %.result: %.raw
	echo "target: $@ prereq: $<" 

%.c %.raw:
	touch $@

clean:
	rm -f $(src_files)
```

## Pattern Rules

Pattern rules are often used but quite confusing. You can look at them as two ways:

- A way to define your own implicit rules
- A simpler form of static pattern rules

Let's start with an example first:

```
# Define a pattern rule that compiles every .c file into a .o file
%.o : %.c
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
```

Pattern rules contain a '%' in the target. This '%' matches any nonempty string, and the other characters match themselves. ‘%’ in a prerequisite of a pattern rule stands for the same stem that was matched by the ‘%’ in the target.

Here's another example:

```
# Define a pattern rule that has no pattern in the prerequisites.
# This just creates empty .c files when needed.
%.c:
   touch $@
```

## Double-Colon Rules

Double-Colon Rules are rarely used, but allow multiple rules to be defined for the same target. If these were single colons, a warning would be printed and only the second set of commands would run.

```
all: blah

blah::
	echo "hello"

blah::
	echo "hello again"
```

---
## !
Sources:
1. https://makefiletutorial.com/

Tags: