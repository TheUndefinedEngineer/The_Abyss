*29-03-2026*

---

> [!tip] Core idea Two binaries (`server`, `client`) each built from a single `.c` file in a flat `src/` directory. Each gets its own explicit source, object, and link rule. No wildcards needed for this layout.

---
## Project layout

```
my_project/
├── src/
│   ├── server.c       ← contains server's main()
│   └── client.c       ← contains client's main()
├── build/
│   └── x86_64-debug/
│       ├── server
│       ├── client
│       └── src/
│           ├── server.o
│           ├── server.d
│           ├── client.o
│           └── client.d
└── Makefile
```

---
## Working Makefile

```makefile
PLATFORM ?= x86_64
BUILD_PROFILE ?= debug

CONFIG_NAME ?= $(PLATFORM)-$(BUILD_PROFILE)
OUTPUT_DIR   = build/$(CONFIG_NAME)

SERVER = $(OUTPUT_DIR)/server
CLIENT = $(OUTPUT_DIR)/client

SERVER_SRC = src/server.c
CLIENT_SRC = src/client.c

SERVER_OBJ = $(OUTPUT_DIR)/src/server.o
CLIENT_OBJ = $(OUTPUT_DIR)/src/client.o

CC  = qcc -Vgcc_nto$(PLATFORM)
CXX = q++ -Vgcc_nto$(PLATFORM)_cxx
LD  = $(CC)

#INCLUDES += -I/path/to/my/lib/include
#LIBS     += -L/path/to/my/lib/$(PLATFORM)/usr/lib -lmylib

CCFLAGS_release  += -O2
CCFLAGS_debug    += -g -O0 -fno-builtin
CCFLAGS_coverage += -g -O0 -ftest-coverage -fprofile-arcs
LDFLAGS_coverage += -ftest-coverage -fprofile-arcs
CCFLAGS_profile  += -g -O0 -finstrument-functions
LIBS_profile     += -lprofilingS

CCFLAGS_all += -Wall -fmessage-length=0
CCFLAGS_all += $(CCFLAGS_$(BUILD_PROFILE))
LDFLAGS_all += $(LDFLAGS_$(BUILD_PROFILE))
LIBS_all    += $(LIBS_$(BUILD_PROFILE))

DEPS = -Wp,-MMD,$(@:%.o=%.d),-MT,$@

# Compile rule
$(OUTPUT_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -c $(DEPS) -o $@ $(INCLUDES) $(CCFLAGS_all) $(CCFLAGS) $<

# Link rules
$(SERVER): $(SERVER_OBJ)
	$(LD) -o $@ $(LDFLAGS_all) $(LDFLAGS) $^ $(LIBS_all) $(LIBS)

$(CLIENT): $(CLIENT_OBJ)
	$(LD) -o $@ $(LDFLAGS_all) $(LDFLAGS) $^ $(LIBS_all) $(LIBS)

all: $(SERVER) $(CLIENT)

clean:
	rm -fr $(OUTPUT_DIR)

rebuild: clean all

.PHONY: all clean rebuild

-include $(SERVER_OBJ:.o=.d)
-include $(CLIENT_OBJ:.o=.d)
```

---
## What was wrong in the original + why it was fixed

|Bug|Symptom|Fix|
|---|---|---|
|`$(TARGET)` used but never assigned|`make all` either silently built nothing or errored — `all: $(TARGET)` resolved to `all:`|Removed `$(TARGET)` entirely; link rules use `$(SERVER)` and `$(CLIENT)` directly|
|Two `all:` rules|Make silently discards the first; `all: $(TARGET)` was dead code|Single `all: $(SERVER) $(CLIENT)`|
|`rwildcard`, `SRCS`, `OBJS` computed but never used|Extra parse work, misleading to read|Removed — flat layout doesn't need recursive glob|
|`-include $(OBJS:%.o=%.d)` tracked the wrong list|Dependency files for `SERVER_OBJ`/`CLIENT_OBJ` were never included; header changes didn't trigger recompile|Changed to `-include $(SERVER_OBJ:.o=.d)` and `-include $(CLIENT_OBJ:.o=.d)`|
|`$^` missing from link rules|Used explicit `$(SERVER_OBJ)` in body instead of `$^` — redundant and fragile if prerequisites change|Replaced with `$^` (expands to all prerequisites of the rule)|

> [!warning] Two `all:` rules is silent data loss Make does **not** error on duplicate target definitions. It picks the last one and discards the first without warning. Always `grep` for duplicate targets if a build seems to do less than expected.

---
## Build commands

```bash
# Default: debug build for x86_64
make

# Release build
make BUILD_PROFILE=release

# Different platform
make PLATFORM=aarch64le

# Both overrides
make PLATFORM=aarch64le BUILD_PROFILE=release

# Build only server
make build/x86_64-debug/server

# Build only client
make build/x86_64-debug/client

# Clean artifacts for current config only
make clean

# Full rebuild
make rebuild
```

> [!note] Config-scoped output `OUTPUT_DIR = build/$(CONFIG_NAME)` means each platform+profile combination gets its own directory. `make clean` only removes the current config's artifacts — other configs are untouched.

---
## Scaling this up

If `server.c` or `client.c` grows into multiple files, promote to per-binary object lists without restructuring the whole Makefile:

```makefile
# Before (single file each)
SERVER_OBJ = $(OUTPUT_DIR)/src/server.o
CLIENT_OBJ = $(OUTPUT_DIR)/src/client.o

# After (multiple files per binary)
SERVER_OBJS = $(OUTPUT_DIR)/src/server.o \
              $(OUTPUT_DIR)/src/server_ipc.o \
              $(OUTPUT_DIR)/src/server_handler.o

CLIENT_OBJS = $(OUTPUT_DIR)/src/client.o \
              $(OUTPUT_DIR)/src/client_send.o

$(SERVER): $(SERVER_OBJS)
	$(LD) -o $@ $(LDFLAGS_all) $(LDFLAGS) $^ $(LIBS_all) $(LIBS)

-include $(SERVER_OBJS:.o=.d)
-include $(CLIENT_OBJS:.o=.d)
```

Or use `rwildcard` with a subdirectory layout — see [[Makefile - QNX Dual-Binary Build Guide]] for that pattern.

---
## Dependency tracking

```makefile
DEPS = -Wp,-MMD,$(@:%.o=%.d),-MT,$@
```

Passed to the compiler in the compile rule. Generates a `.d` file alongside each `.o`.

```makefile
-include $(SERVER_OBJ:.o=.d)
-include $(CLIENT_OBJ:.o=.d)
```

The substitution `$(SERVER_OBJ:.o=.d)` expands `$(OUTPUT_DIR)/src/server.o` → `$(OUTPUT_DIR)/src/server.d`. The leading `-` suppresses the "file not found" error on first build before `.d` files exist.

**Effect:** Change a `.h` that `server.c` includes → only `server.o` rebuilds, not `client.o`.

---
## Build flow

```
src/server.c ──► [qcc -c] ──► build/x86_64-debug/src/server.o ──► [qcc link] ──► build/x86_64-debug/server
                                            │
                                    server.d (auto-generated,
                                    tracks header deps)

src/client.c ──► [qcc -c] ──► build/x86_64-debug/src/client.o ──► [qcc link] ──► build/x86_64-debug/client
```

---

Sources:
1. https://claude.ai/share/183eb53a-7206-4d5d-b775-64c23f0a529f

Tags: #guide #linux #qnx