#!/usr/bin/env bash
set -e

BUILD_DIR="build"
TOOLCHAIN="cmake/gcc-arm-none-eabi.cmake"
ELF_FILE=$(find "$BUILD_DIR" -name "*.elf" 2>/dev/null | head -n 1)

configure() {
    echo "Configuring project..."
    cmake -B "$BUILD_DIR" -S . -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN"
}

clean() {
    echo "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
}

build() {
    if [ ! -f "$BUILD_DIR/CMakeCache.txt" ]; then
        configure
    fi
    echo "Building..."
    cmake --build "$BUILD_DIR"
}


flash() {
    build
    ELF_FILE=$(find "$BUILD_DIR" -name "*.elf" | head -n 1)
    echo "Flashing $ELF_FILE ..."
    openocd -f interface/stlink.cfg \
            -f target/stm32f4x.cfg \
            -c "program $ELF_FILE verify reset exit"
}

debug() {
    build
    ELF_FILE=$(find "$BUILD_DIR" -name "*.elf" | head -n 1)

    echo "Starting OpenOCD..."
    openocd -f interface/stlink.cfg -f target/stm32f4x.cfg &
    OPENOCD_PID=$!

    sleep 2

    echo "Starting GDB..."
    arm-none-eabi-gdb "$ELF_FILE" \
        -ex "target remote localhost:3333" \
        -ex "monitor reset halt"

    kill $OPENOCD_PID
}

case "$1" in
    clean)
        clean
        ;;
    rebuild)
        echo "Rebuilding from scratch..."
        clean
        build
        ;;
    flash)
        flash
        ;;
    debug)
        debug
        ;;
    *)
        build
        ;;
esac
