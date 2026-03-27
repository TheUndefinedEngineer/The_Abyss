**A Reproducible CMake-Based Embedded Workflow Guide**

A clean, reproducible, easy to use workflow for STM32 (Cortex‑M4) development on NixOS using CMake.

This document contains:

* Common errors encountered
* Root causes
* Correct fixes
* Reusable template structure

---

# 1. Project Structure

```bash
project/
├── flake.nix
├── flake.lock
├── CMakeLists.txt
├── cmake/
│   └── gcc-arm-none-eabi.cmake
├── Src/
├── Inc/
├── Drivers/
└── build/ 
└── build.sh
```

# 2. ARM Toolchain Configuration

Canonical flag set for STM32F401 in /cmake/gcc-arm-none-eabi.camke:

- Need to add: `-mthumb`

Rules:

* Do NOT mix hard and softfp
* Do NOT define flags multiple times
* Keep flags as ONE string (not list)

Correct example:

```cmake
set(ARM_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
```

Incorrect (causes shell splitting errors):

```cmake
set(ARM_FLAGS
  "-mcpu=cortex-m4"
  "-mthumb"
)
```
- Remove `--specs=nano.specs` (will update the full line later)



# 3. Using Templates

We use 2 different templates which can be copied into the project:
  1. [[STM32-Develop - NixOS]] - flake.nix
```bash
cp -r ~/Template/stm32-develop/flake.nix ~/Workspace/< project name >
``` 

  2. [[STM32-Build]] - build.sh
```bash
cp -r ~/Template/stm32-build/build.sh ~/Workspace/< project name >
``` 

## 3.1 Development Environment (stm32-develop)

Controls the toolchain and build tools.

Contains:

* `flake.nix`

Provides:

* arm-none-eabi-gcc
* cmake
* ninja
* gdb
* openocd

In project dir run:

```bash
nix develop
```

Purpose:

* Ensures compiler exists
* Locks toolchain version
* Prevents "works on my machine" issues
* Avoids system pollution

This does NOT build the project.
It only provides the environment.

---

## 3.2 Build System (stm32-build)

The `build.sh` contains the following commands:
```bash
./build.sh           # Builds the project
./build.sh clean     # Cleans the build
./build.sh rebuild   # Cleans and builds the project
./build.sh flash     # Flashes the .elf using openocd
./build.sh debug     # Opens gdb
```
*Note: Need to fix debug mode*

- `flash` needs upadating so it works in vs code terminal but for now it works in bash.

- Run the commands in the first level of the project.


### What each command does

#### First build

```bash
nix develop
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/gcc-arm-none-eabi.cmake
cmake --build .
```

#### After Code Changes

```bash
cmake --build build
```

#### Clean + Rebuild

```bash
rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/gcc-arm-none-eabi.cmake
cmake --build .
```

#### flash
```bash
# will update
```

#### debug
- So it keeps giving python error so for now I used this command
```bash
# will update when i figure out how to make it work - python version missmatch error
#Temporary fix
gdb -nx build/<project name>.elf

```


---

# 4. Common Errors and Fixes

1. Error: Bad CMake executable "cube-cmake"
    Cause: VSCode overriding CMake path.
    Fix: Remove custom `cmake.cmakePath` in settings.

2. Error: arm-none-eabi-gcc not found
    Cause: Not inside `nix develop` shell.
    Fix: Run `nix develop`.

3. Error: "isb 0xF" not supported
    Cause: Missing `-mthumb` flag.
    Fix: Ensure `-mthumb` is always present.

4. Error: VFP register argument mismatch
    Cause: Mixing `-mfloat-abi=hard` and `softfp`.
    Fix: Use only ONE ABI everywhere.

5. Error: cannot find -lg_nano
    Cause: Using `--specs=nano.specs` without nano library.
    Fix: Remove nano specs OR ensure toolchain supports it.

6. Error: "no input files" during compiler test
    Cause: Flags defined as list instead of string.
    Fix: Combine into single string.
---

Workflow:

1. Enter environment → `nix develop`
2. Build → `.build.sh`
3. Rebuild only when toolchain or config changes

[[STM32 Project Templates]]

Tags: #guide #microcontroller  #todo 