*29-03-2026* 

---
> [!tip] Core idea A Makefile with multiple `.c` files has two jobs: **compile** each `.c` into a `.o` object file independently, then **link** all `.o` files into one binary. Keep these stages separate in your rules.

---
## Project layouts

### 2-file project (flat)

```
my_project/
├── main.c
├── utils.c
├── utils.h
└── Makefile
```

### N-file project (scalable)

```
my_project/
├── src/
│   ├── main.c
│   ├── utils.c
│   ├── sensor.c
│   └── comms.c
├── include/
│   └── *.h
├── build/          ← created automatically by make
└── Makefile
```

---
## Makefile — 2-file version

```makefile
# Variables
CC      := gcc
CFLAGS  := -Wall -Wextra -g
TARGET  := my_app
SRCS    := main.c utils.c
OBJS    := $(SRCS:.c=.o)   # expands to: main.o utils.o

# Default target — builds the binary
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Pattern rule — compiles any .c into a .o
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: clean
```

> [!note] Substitution reference `$(SRCS:.c=.o)` replaces every `.c` extension in `SRCS` with `.o`. You only maintain the `SRCS` list — `OBJS` derives from it automatically.

---
## Makefile — N-file scalable version

```makefile
CC       := gcc
CFLAGS   := -Wall -Wextra -g -I./include
TARGET   := my_app
BUILDDIR := build

# Wildcard: grab every .c in src/ automatically
SRCS     := $(wildcard src/*.c)

# Derive .o paths under build/
OBJS     := $(patsubst src/%.c, $(BUILDDIR)/%.o, $(SRCS))

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Order-only prerequisite: build/ must exist first
$(BUILDDIR)/%.o: src/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR) $(TARGET)

.PHONY: clean
```

> [!tip] Adding a new source file Drop `newmodule.c` into `src/` and run `make`. The wildcard picks it up automatically — no Makefile edits needed.

---
## QNX cross-compile variant

Replace only the compiler variables. Everything else is identical.

```makefile
CC      := qcc
CFLAGS  := -Vgcc_ntoaarch64le -Wall -g -I./include
LDFLAGS := -Vgcc_ntoaarch64le
```

> [!note] `-V` flag The `-V` flag selects the target variant in `qcc`. Use `ntoaarch64le` for ARM64 (Raspberry Pi 5), `ntox86_64` for x86 targets.

---
## Adding libraries

Libraries go in `LDLIBS`, appended **after** object files in the link step.

```makefile
LDLIBS := -lm -lpthread

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)
```

> [!warning] Link order matters `LDFLAGS` (linker flags, e.g. `-L/path`) goes **before** object files. `LDLIBS` (libraries) goes **after**. Wrong order causes `undefined reference` errors with static libs.

---
## Automatic variables

|Variable|Expands to|Typical use|
|---|---|---|
|`$@`|Current target name|Output file in compile/link|
|`$<`|First prerequisite only|The single `.c` input in a compile rule|
|`$^`|All prerequisites (deduplicated)|All `.o` files in the link step|
|`$?`|Prerequisites newer than target|Incremental operations|
|`$*`|Stem matched by `%` in pattern|Filename without extension|

---
## Make functions

|Function|What it does|
|---|---|
|`$(wildcard src/*.c)`|Returns all `.c` files in `src/` as a space-separated list|
|`$(patsubst a,b,list)`|Replaces pattern `a` with `b` across every word in `list`|
|`$(SRCS:.c=.o)`|Shorthand substitution: swap `.c` → `.o` in `SRCS`|
|`$(notdir path)`|Strips the directory part from a path|
|`$(addprefix dir/,list)`|Prepends a prefix to every word in `list`|

---
## Common errors

### Missing separator

```
Makefile:5: *** missing separator. Stop.
```

**Cause:** Recipe lines indented with spaces instead of a hard tab.

```makefile
# WRONG — spaces
target: dep
    gcc main.c -o app

# RIGHT — hard tab (\t)
target: dep
	gcc main.c -o app
```

> [!warning] Every recipe line **must** start with a tab (`\t`), not spaces. Set your editor's file type to `Makefile` to enforce this.

---
### Multiple definition of `main`

```
multiple definition of 'main'
```

**Cause:** Two or more `.c` files define `main()`.  
**Fix:** Only one file has `main()`. All other files are modules that export functions through a header.

---
### Undefined reference

```
undefined reference to 'sensor_init'
```

**Cause 1:** `sensor.c` is not in `SRCS`.

```makefile
# Missing file — add it explicitly or use wildcard
SRCS := main.c sensor.c
SRCS := $(wildcard src/*.c)
```

**Cause 2:** A library is not linked.

```makefile
LDLIBS := -lm    # e.g. for math.h functions
```
---
### Header not found

```
fatal error: utils.h: No such file or directory
```

**Fix:** Add the include directory to `CFLAGS`.

```makefile
CFLAGS := -Wall -I./include
```
---
## Debug commands

```bash
make -n          # dry run — prints commands without executing
make -p          # dump all built-in rules and variables
make clean && make   # force full rebuild
```

Add inside a Makefile to print a variable's value during parse:

```makefile
$(info $(SRCS))
```
---
## Build flow

```
main.c ──► [gcc -c] ──► main.o ──┐
utils.c ─► [gcc -c] ──► utils.o ──┤──► [gcc link] ──► my_app
sensor.c ► [gcc -c] ──► sensor.o ┘
```

Each `.c` compiles independently. `make` only recompiles files whose source or headers have changed since the last build (incremental builds). Run `make clean && make` to force a full rebuild.

---

Sources:
1. https://claude.ai/share/183eb53a-7206-4d5d-b775-64c23f0a529f

Tags: #guide #reference #microcontroller #linux 