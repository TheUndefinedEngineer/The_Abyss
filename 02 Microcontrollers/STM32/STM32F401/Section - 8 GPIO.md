*19-04-2026* 
## Overview

Each GPIO port (A–E, H) controls up to 16 pins. Every pin is independently configurable via memory-mapped registers on the **AHB1 bus**. All GPIO registers are 32-bit and must be accessed as word, half-word, or byte — never bit-band for configuration (use BSRR for atomic output instead).

> [!important] Clock must be enabled first Before touching any GPIO register, enable the port clock in `RCC_AHB1ENR`. Writing to GPIO registers without the clock enabled has no effect and no error.
> 
> ```c
> RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN; // Enable GPIOB clock
> ```

---
## Reset State

After reset, all I/Os default to **input floating** mode — except the debug pins:

|Pin|Reset State|
|---|---|
|PA13 (JTMS/SWDIO)|AF, pull-up|
|PA14 (JTCK/SWCLK)|AF, pull-down|
|PA15 (JTDI)|AF, pull-up|
|PB3 (JTDO)|AF, floating|
|PB4 (NJTRST)|AF, pull-up|

> [!warning] Debug pin gotcha PA13, PA14, PA15, PB3, PB4 are owned by the debugger at reset. If you need these as GPIO, you must explicitly disable JTAG via SYSCFG — otherwise your writes to MODER will appear to work but the debugger retakes control on the next reset.

---
## Pin Configuration Registers

Four registers control _how_ a pin behaves. They apply to **all modes** (input, output, AF, analog).

### 1. GPIOx_MODER — Mode Register

**Offset:** `0x00` | **2 bits per pin**

|MODER[1:0]|Mode|
|---|---|
|`00`|Input (reset state for most pins)|
|`01`|General purpose output|
|`10`|Alternate function|
|`11`|Analog|

```c
// Set PB6 to Alternate Function mode
GPIOB->MODER &= ~(0x3 << (6 * 2));   // Clear bits
GPIOB->MODER |=  (0x2 << (6 * 2));   // Set AF mode (10)
```

> [!note] Non-zero reset values on PA and PB GPIOA_MODER resets to `0xA800_0000` and GPIOB to `0x0000_0280` — these encode the debug pin AF modes. All other ports reset to `0x0000_0000`.

---
### 2. GPIOx_OTYPER — Output Type Register

**Offset:** `0x04` | **1 bit per pin** (upper 16 bits reserved)

|OT[y]|Type|
|---|---|
|`0`|Push-pull (reset state)|
|`1`|Open-drain|

```c
// Set PB6 to open-drain (required for I2C)
GPIOB->OTYPER |= (1 << 6);
```

> [!important] When to use open-drain I2C **requires** open-drain. The I2C spec uses a wired-AND bus — the line is pulled high by an external resistor, and any device can pull it low. Push-pull would fight the pull-up resistor and damage the bus.

---
### 3. GPIOx_OSPEEDR — Output Speed Register

**Offset:** `0x08` | **2 bits per pin**

|OSPEEDR[1:0]|Speed|
|---|---|
|`00`|Low speed|
|`01`|Medium speed|
|`10`|High speed|
|`11`|Very high speed|

```c
// Set PB6 to medium speed
GPIOB->OSPEEDR &= ~(0x3 << (6 * 2));
GPIOB->OSPEEDR |=  (0x1 << (6 * 2));
```

> [!tip] How to choose speed Speed controls the slew rate of the output driver — faster = steeper edges = more EMI and power.
> 
> - **GPIO toggle / LED:** Low speed is fine
> - **I2C (100–400 kHz):** Low or medium
> - **SPI / UART high baud:** High or very high
> - Only raise speed if signal integrity problems appear. Default to low.

---
### 4. GPIOx_PUPDR — Pull-up/Pull-down Register

**Offset:** `0x0C` | **2 bits per pin**

|PUPDR[1:0]|Configuration|
|---|---|
|`00`|No pull (floating)|
|`01`|Pull-up|
|`10`|Pull-down|
|`11`|Reserved|

```c
// Set PB6 to no pull (I2C uses external pull-ups)
GPIOB->PUPDR &= ~(0x3 << (6 * 2));
```

> [!warning] Internal pull-ups are weak (~40 kΩ typical) For I2C, always use **external** pull-up resistors (typically 4.7 kΩ for 100 kHz, 2.2 kΩ for 400 kHz). The internal pull-ups are too weak for reliable I2C at any speed. Set PUPDR to `00` (no pull) when using external resistors.

---
## Data Registers

### GPIOx_IDR — Input Data Register

**Offset:** `0x10` | **Read-only** | Lower 16 bits valid

Sampled every AHB clock cycle. Reading this always gives the **current pin state**, regardless of what the output register says.

```c
// Read pin state of PB5
uint8_t state = (GPIOB->IDR >> 5) & 0x1;
```

---
### GPIOx_ODR — Output Data Register

**Offset:** `0x14` | **Read/write** | Lower 16 bits valid

Controls output value when in output or AF mode. Reading it gives **last written value**, not the actual pin state.

```c
// Set PB5 high (not atomic — avoid in IRQ context)
GPIOB->ODR |= (1 << 5);
```

> [!danger] ODR read-modify-write is NOT atomic `GPIOB->ODR |= (1 << 5)` compiles to a read → OR → write sequence. An IRQ between the read and write can corrupt other bits. Use BSRR instead for any output toggling in real code.

---
## BSRR — Bit Set/Reset Register (Atomic Output)

**Offset:** `0x18` | **Write-only** | 32 bits

|Bits [31:16]|Bits [15:0]|
|---|---|
|Reset bits (BR) — write 1 to clear ODR bit|Set bits (BS) — write 1 to set ODR bit|

Writing 0 to any bit has no effect. If both set and reset are written for the same pin simultaneously, **set wins**.

```c
// Atomic set PB5 high
GPIOB->BSRR = (1 << 5);

// Atomic set PB5 low
GPIOB->BSRR = (1 << (5 + 16));

// Toggle PB5 — still requires read, but less dangerous
GPIOB->BSRR = (GPIOB->ODR & (1 << 5)) ? (1 << (5 + 16)) : (1 << 5);
```

> [!tip] Always use BSRR for output, never ODR directly BSRR is a single 32-bit write — inherently atomic on the AHB bus. No IRQ can corrupt other pins. This is the correct pattern for all output toggling in production code.

---
## Alternate Function Configuration

### The AF Mux

Each pin has a 16-input mux (AF0–AF15) hardwired in silicon. You select which peripheral drives/reads the pin by writing the AF number. The mapping is **fixed per pin** — you cannot arbitrarily assign functions, only choose from what ST wired.

> [!important] Always check the datasheet AF table The RM tells you _how_ to configure AF. The **STM32F401 datasheet** (not the RM) has Table 9 — "Alternate function mapping" — which tells you _which AF number_ maps to which peripheral on which specific pin. You need both documents.

**Common AF numbers for STM32F401:**

|AF#|Peripheral|
|---|---|
|AF0|System (JTAG, SWD, MCO)|
|AF1|TIM1, TIM2|
|AF2|TIM3, TIM4, TIM5|
|AF3|TIM9, TIM10, TIM11|
|AF4|I2C1, I2C2, I2C3|
|AF5|SPI1, SPI2, SPI3, SPI4|
|AF7|USART1, USART2|
|AF8|USART6|

---
### AF Selection Registers

Split into two registers because 16 pins × 4 bits = 64 bits — doesn't fit in 32.

|Register|Offset|Covers|
|---|---|---|
|`GPIOx_AFRL`|`0x20`|Pins 0–7 (4 bits each)|
|`GPIOx_AFRH`|`0x24`|Pins 8–15 (4 bits each)|

```c
// Select AF4 (I2C) on PB6 (pin 6 → AFRL)
GPIOB->AFR[0] &= ~(0xF << (6 * 4));   // Clear 4-bit field
GPIOB->AFR[0] |=  (0x4 << (6 * 4));   // Write AF4

// Select AF4 (I2C) on PB8 (pin 8 → AFRH, index into AFR[1])
GPIOB->AFR[1] &= ~(0xF << ((8 - 8) * 4));
GPIOB->AFR[1] |=  (0x4 << ((8 - 8) * 4));
```

> [!note] AFR[0] and AFR[1] in CMSIS In the CMSIS struct, `GPIOx->AFR[0]` = AFRL, `GPIOx->AFR[1]` = AFRH. When indexing AFRH, subtract 8 from the pin number to get the bit offset within the register.

---
### Full Alternate Function Setup Sequence

This is the mandatory order. Skipping or reordering steps silently breaks things.

```c
// Example: Configure PB6 as I2C1_SCL (AF4, open-drain)

// Step 0: Enable GPIOB clock
RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;

// Step 1: Set MODER to Alternate Function (10)
GPIOB->MODER &= ~(0x3 << (6 * 2));
GPIOB->MODER |=  (0x2 << (6 * 2));

// Step 2: Set output type to open-drain (I2C requirement)
GPIOB->OTYPER |= (1 << 6);

// Step 3: Set speed (medium is sufficient for I2C at 400 kHz)
GPIOB->OSPEEDR &= ~(0x3 << (6 * 2));
GPIOB->OSPEEDR |=  (0x1 << (6 * 2));

// Step 4: No internal pull-up (using external 4.7k resistors)
GPIOB->PUPDR &= ~(0x3 << (6 * 2));

// Step 5: Select AF4 in AFRL (pin 6 → AFR[0])
GPIOB->AFR[0] &= ~(0xF << (6 * 4));
GPIOB->AFR[0] |=  (0x4 << (6 * 4));
```

> [!danger] Step 1 is not optional If MODER is not set to `10` (AF mode), the AFR value is completely ignored — the peripheral never gets connected to the pin. This is the most common AF configuration mistake.

---
## Port Bit Configuration Truth Table

Condensed from RM0368 Table 24:

|MODER|OTYPER|PUPDR|Result|
|---|---|---|---|
|`01`|`0`|`00`|GP Output, Push-Pull|
|`01`|`0`|`01`|GP Output, Push-Pull + Pull-Up|
|`01`|`1`|`00`|GP Output, Open-Drain|
|`01`|`1`|`01`|GP Output, Open-Drain + Pull-Up|
|`10`|`0`|`00`|AF Output, Push-Pull|
|`10`|`1`|`00`|AF Output, Open-Drain|
|`10`|`1`|`01`|AF Output, Open-Drain + Pull-Up|
|`00`|`x`|`00`|Input, Floating|
|`00`|`x`|`01`|Input, Pull-Up|
|`00`|`x`|`10`|Input, Pull-Down|
|`11`|`x`|`00`|Analog|

---
## GPIO Base Addresses

|Port|Base Address|
|---|---|
|GPIOA|`0x4002_0000`|
|GPIOB|`0x4002_0400`|
|GPIOC|`0x4002_0800`|
|GPIOD|`0x4002_0C00`|
|GPIOE|`0x4002_1000`|
|GPIOH|`0x4002_1C00`|

---
## Register Map Summary

|Offset|Register|Function|
|---|---|---|
|`0x00`|MODER|Pin mode (input/output/AF/analog)|
|`0x04`|OTYPER|Output type (push-pull/open-drain)|
|`0x08`|OSPEEDR|Output slew rate|
|`0x0C`|PUPDR|Pull-up / pull-down|
|`0x10`|IDR|Input data (read-only)|
|`0x14`|ODR|Output data (read/write)|
|`0x18`|BSRR|Atomic set/reset (write-only)|
|`0x1C`|LCKR|Pin config lock|
|`0x20`|AFRL|AF select pins 0–7|
|`0x24`|AFRH|AF select pins 8–15|

---
## Common Gotchas

> [!warning] Gotcha 1 — Forgot to enable RCC clock The most common mistake. GPIO peripheral is gated off by default. No error, no fault — writes just vanish.

> [!warning] Gotcha 2 — MODER not set to AF before writing AFR AFR value is irrelevant if MODER isn't `10`. Always set MODER first.

> [!warning] Gotcha 3 — Wrong AFRL/AFRH register Pin 0–7 → `AFR[0]` (AFRL). Pin 8–15 → `AFR[1]` (AFRH). When using AFRH, bit offset = `(pin - 8) * 4`.

> [!warning] Gotcha 4 — Using ODR instead of BSRR for output ODR read-modify-write is not atomic. Always use BSRR in production code, especially anywhere an IRQ could fire.

> [!warning] Gotcha 5 — Internal pull-ups for I2C Internal pull-ups (~40 kΩ) are too weak for I2C. Always use external resistors (4.7 kΩ @ 100 kHz, 2.2 kΩ @ 400 kHz) and set PUPDR to `00`.



---
## !
Sources:

Tags: #reference 