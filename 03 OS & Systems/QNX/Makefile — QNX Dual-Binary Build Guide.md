*29-03-2026* 

---
> [!tip] Core idea Two binaries (`server`, `client`) built from the same Makefile. Each gets its own source directory and object list. Shared code lives in `src/common/` and links into both. Only the **link rules** differ — the compile rule is shared.

---
## Project layout

```
my_project/
├── src/
│   ├── server/          ← server sources + server's main.c
│   │   ├── main.c
│   │   └── server_logic.c
│   ├── client/          ← client sources + client's main.c
│   │   ├── main.c
│   │   └── client_logic.c
│   └── common/          ← shared code, no main()
│       ├── ipc_utils.c
│       └── checksum.c
├── include/
│   └── *.h
├── build/               ← created automatically
│   └── aarch64le-debug/
│       ├── server
│       └── client
└── Makefile
```

> [!warning] One `main()` per binary `src/server/` and `src/client/` each have exactly one `main.c`. `src/common/` must **never** define `main()` — it links into both binaries.

---
## Full Makefile

```makefile
# Build architecture/variant string
# Possible values: x86, armv7le, aarch64le, etc.
PLATFORM ?= aarch64le

# Build profile
# Possible values: release, debug, profile, coverage
BUILD_PROFILE ?= debug

CONFIG_NAME ?= $(PLATFORM)-$(BUILD_PROFILE)
OUTPUT_DIR  = build/$(CONFIG_NAME)

SERVER = $(OUTPUT_DIR)/server
CLIENT = $(OUTPUT_DIR)/client

# Compiler definitions
CC  = qcc -Vgcc_nto$(PLATFORM)
CXX = q++ -Vgcc_nto$(PLATFORM)_cxx
LD  = $(CC)

# User defined include/preprocessor flags and libraries
#INCLUDES += -I/path/to/my/lib/include
#LIBS     += -L/path/to/my/lib/$(PLATFORM)/usr/lib -lmylib

# Compiler flags per build profile
CCFLAGS_release  += -O2
CCFLAGS_debug    += -g -O0 -fno-builtin
CCFLAGS_coverage += -g -O0 -ftest-coverage -fprofile-arcs
LDFLAGS_coverage += -ftest-coverage -fprofile-arcs
CCFLAGS_profile  += -g -O0 -finstrument-functions
LIBS_profile     += -lprofilingS

# Generic flags (absorb profile-specific flags)
CCFLAGS_all += -Wall -fmessage-length=0
CCFLAGS_all += $(CCFLAGS_$(BUILD_PROFILE))
LDFLAGS_all += $(LDFLAGS_$(BUILD_PROFILE))
LIBS_all    += $(LIBS_$(BUILD_PROFILE))

# Dependency tracking: generates a .d file alongside each .o
DEPS = -Wp,-MMD,$(@:%.o=%.d),-MT,$@

# Recursive wildcard helper: $(call rwildcard, dir, ext)
rwildcard = $(wildcard $(addprefix $1/*.,$2)) \
            $(foreach d,$(wildcard $1/*),$(call rwildcard,$d,$2))

# Per-binary source and object lists
SERVER_SRCS = $(call rwildcard, src/server, c)
SERVER_OBJS = $(addprefix $(OUTPUT_DIR)/,$(addsuffix .o,$(basename $(SERVER_SRCS))))

CLIENT_SRCS = $(call rwildcard, src/client, c)
CLIENT_OBJS = $(addprefix $(OUTPUT_DIR)/,$(addsuffix .o,$(basename $(CLIENT_SRCS))))

COMMON_SRCS = $(call rwildcard, src/common, c)
COMMON_OBJS = $(addprefix $(OUTPUT_DIR)/,$(addsuffix .o,$(basename $(COMMON_SRCS))))

# Compile rule (shared for all .c under src/)
$(OUTPUT_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -c $(DEPS) -o $@ $(INCLUDES) $(CCFLAGS_all) $(CCFLAGS) $<

# Link rules
$(SERVER): $(SERVER_OBJS) $(COMMON_OBJS)
	$(LD) -o $@ $(LDFLAGS_all) $(LDFLAGS) $^ $(LIBS_all) $(LIBS)

$(CLIENT): $(CLIENT_OBJS) $(COMMON_OBJS)
	$(LD) -o $@ $(LDFLAGS_all) $(LDFLAGS) $^ $(LIBS_all) $(LIBS)

# Top-level targets
all: $(SERVER) $(CLIENT)

clean:
	rm -fr $(OUTPUT_DIR)

rebuild: clean all

.PHONY: all clean rebuild

# Pull in generated dependency files (rebuild on header changes)
-include $(SERVER_OBJS:%.o=%.d)
-include $(CLIENT_OBJS:%.o=%.d)
-include $(COMMON_OBJS:%.o=%.d)
```

---
## What changed from the original

|Original|Fixed|Why|
|---|---|---|
|Single `SRCS` glob over all of `src/`|Separate `SERVER_SRCS`, `CLIENT_SRCS`, `COMMON_SRCS`|Without separation, both binaries get each other's `main()` → `multiple definition of 'main'`|
|Link rule used `$(TARGET)` (undefined)|Two explicit rules: `$(SERVER)` and `$(CLIENT)`|`$(TARGET)` was never assigned — linker step would fail immediately|
|Single `-include` for `.d` files|Three `-include` lines, one per object list|Ensures header dependency tracking works for all three source trees|
|No `.PHONY` declaration|`.PHONY: all clean rebuild` added|Prevents make from confusing targets with files of the same name|

---
## Build commands

```bash
# Default: debug build for aarch64le
make

# Release build
make BUILD_PROFILE=release

# Cross-compile for a different target
make PLATFORM=armv7le

# Both overrides together
make PLATFORM=x86 BUILD_PROFILE=release

# Clean build artifacts for current config
make clean

# Full rebuild (clean + all)
make rebuild

# Build only the server
make build/aarch64le-debug/server

# Build only the client
make build/aarch64le-debug/client
```

> [!note] `OUTPUT_DIR` is config-scoped Each `PLATFORM`/`BUILD_PROFILE` combination produces its own directory under `build/`. Switching configs does not overwrite previous build artifacts.

---
## Build profiles explained

|Profile|Flags|Use case|
|---|---|---|
|`debug`|`-g -O0 -fno-builtin`|Default. Full debug symbols, no optimisation, no builtin substitution|
|`release`|`-O2`|Production. Optimised, no debug symbols|
|`coverage`|`-g -O0 -ftest-coverage -fprofile-arcs`|gcov/lcov code coverage measurement|
|`profile`|`-g -O0 -finstrument-functions` + `-lprofilingS`|QNX application profiling (links profiling stub)|

---
## Dependency tracking (`.d` files)

```makefile
DEPS = -Wp,-MMD,$(@:%.o=%.d),-MT,$@
```

This tells `cpp` to write a `.d` file next to every `.o`. The `-include` lines at the bottom pull them in on subsequent runs.

**Effect:** If you change a `.h` file, only the `.c` files that `#include` it are recompiled. Without this, a header change is invisible to make and you get stale object files.

```
build/aarch64le-debug/src/server/main.o   ← object
build/aarch64le-debug/src/server/main.d   ← dependency list (auto-generated)
```

> [!note] The `-include` (with leading dash) suppresses the error if `.d` files don't exist yet (first build). On subsequent builds they are present and included normally.

---
## `rwildcard` explained

```makefile
rwildcard = $(wildcard $(addprefix $1/*.,$2)) \
            $(foreach d,$(wildcard $1/*),$(call rwildcard,$d,$2))
```

Standard `$(wildcard src/*.c)` only finds files **one level deep**. `rwildcard` recurses into subdirectories.

```makefile
# Usage
SERVER_SRCS = $(call rwildcard, src/server, c)
# Returns: src/server/main.c src/server/logic/handler.c ...
```

---
## Common errors

### `multiple definition of 'main'`

**Cause:** Both `src/server/` and `src/client/` are being fed into the same object list.  
**Fix:** Use separate `SERVER_SRCS` and `CLIENT_SRCS` — never a single glob over all of `src/`.

### `$(TARGET): No such target`

**Cause:** `TARGET` was referenced in a link rule but never assigned.  
**Fix:** Use `$(SERVER)` and `$(CLIENT)` directly as link rule targets.

### Object file path mismatch

**Cause:** `$(addprefix $(OUTPUT_DIR)/, ...)` produces `build/config/src/server/main.o` but the compile rule looks for `$(OUTPUT_DIR)/%.o: %.c` — this only works if the pattern stem includes `src/server/main`.  
**Fix:** The compile rule `$(OUTPUT_DIR)/%.o: %.c` matches correctly because `$(basename $(SERVER_SRCS))` preserves the full relative path including `src/server/`.

---
## Build flow

```
src/server/main.c ──► [qcc -c] ──► build/aarch64le-debug/src/server/main.o ──┐
src/server/logic.c ─► [qcc -c] ──► build/.../server/logic.o ─────────────────┤──► [qcc link] ──► build/.../server
src/common/ipc.c ───► [qcc -c] ──► build/.../common/ipc.o ──────────────────┬┘
                                                                              │
src/client/main.c ──► [qcc -c] ──► build/.../client/main.o ──────────────────┤
src/client/send.c ──► [qcc -c] ──► build/.../client/send.o ──────────────────┴──► [qcc link] ──► build/.../client
```

---

Sources:
1. https://claude.ai/share/183eb53a-7206-4d5d-b775-64c23f0a529f

Tags: #guide #qnx #linux