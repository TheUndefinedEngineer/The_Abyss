*05-05-2026* 
```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```
---
## Required Libraries

```c
include <stdint.h>
```
### `stdint.h`

---
## Task 1 - Led blinking

**Step 1:** Find boundary address in the register boundary address in RM0368 Section - 2.3

|    Boundary addresses     | Peripheral |
| :-----------------------: | :--------: |
| 0x4002 3800 - 0x4002 3BFF |    RCC     |
| 0x4002 0800 - 0x4002 0BFF |   GPIOC    |
> [!question] Why GPIOC?
> PC13 pin linked to an inbuilt LED on STM32F401CCU6 which makes starting point easier.

**Step 2:** Create pointers in main.c to access the register.
```c
volatile uint32_t * const RCC_AHB1ENR = (volatile uint32_t *)(0x40023800 + 0x30);
*RCC_AHB1ENR |= (1 << 2); // enable GPIOC clock
```
```
volatile   uint32_t   *   const   RCC_AHB1ENR
   │           │      │     │
   │           │      │     └── pointer is fixed, can't point elsewhere
   │           │      └──────── it's a pointer
   │           └─────────────── points to a 32-bit value
   └─────────────────────────── that value is hardware-controlled, don't optimize
```

> [!warning] 
> ```c
> const volatile uint32_t *p  // the VALUE it points to is const — you can't write to the register
  volatile uint32_t * const p  // the POINTER itself is const — you can't point it elsewhere
> ```

| Pointers      | Address           |                                      |
| ------------- | ----------------- | ------------------------------------ |
| RCC_AHB1ENR   | 0x40023800 + 0x30 | Peripheral clock enable register     |
| GPIOC_MODER   | 0x40020800        | GPIO port mode register              |
| GPIOC_OSPEEDR | 0x40020800 + 0x08 | GPIO port output speed register      |
| GPIOC_PUPDR   | 0x40020800 + 0x0C | GPIO port pull-up/pull-down register |
| GPIOC_BSRR    | 0x40020800 + 0x18 | GPIO port bit set/reset register     |
> [!question] Why BSRR over ODR?
> For atomic bit set/reset, the ODR bits can be individually set and reset by writing to the GPIOx_BSRR register.

**Step 3:** Set the bits according to the pin number from the reference manual to enable clock, gpio out, gpio speed, and pull down.

Set bit 2 to 1 to enable GPIOCEN - `IO port C clock enable`
```c
*RCC_AHB1ENR |= (1 << 2);
```

Clear bits for pin 13 which is bits 26 and 27 in the register moder and set output mode.
```c
*GPIOC_MODER = (*GPIOC_MODER & ~(0x03 << 26)) | (0x01 << 26);
```

Clear bits for pin 13 which is bits 26 and 27 in the register ospeedr and set medium speed.
```c
*GPIOC_OSPEEDR = (*GPIOC_OSPEEDR & ~(0x03 << 26)) | (0x01 << 26);
```

Clear bits for pin 13 which is bits 26 and 27 in the register pupdr and set no pull-up. no pull-down.
```c
*GPIOC_PUPDR = (*GPIOC_PUPDR & ~(0x03 << 26)) | (0x00 << 26);
```

**Step 4:** Create a while loop and use the BSRR to set and reset the pin and for loop for delay to blink led.

```c
while(1){
	*GPIOC_BSRR = (1 << 13);
	for(volatile int i = 0; i < 100000; i++);
	*GPIOC_BSRR = (1 << (13+16));
	for(volatile int i = 0; i < 100000; i++);
}
```

> [!question] Difference between `*GPIOC_BSRR =` and `*GPIOC_BSRR |=`.
> `*GPIOC_BSRR = value` directly writes a GPIO set/reset command, while `*GPIOC_BSRR |= value` unnecessarily performs a read-modify-write operation on a write-only action register like BSRR.

**Step 5:** Run `make clean` and the `make all` to generate the binaries.

**Step 6:** Run [[OpenOCD - Open On Chip Debugger]] using `make load` to load the binary onto the STM32.

**Step 7:** Using [[Linux Commands#telnet]] or [[GDB - GNU Debugger]] to enter debug session to halt and reset the controller and test its working.

---
## Task 2 - Spinning Motors

> [!Note]
> Some details are not written as they are already present in `Task 1`.

**Step 1:** Find boundary address in the register boundary address in RM0368 Section - 2.3

|    Boundary addresses     | Peripheral |
| :-----------------------: | :--------: |
| 0x4002 0000 - 0x4002 03FF |   GPIOA    |
| 0x4002 0400 - 0x4002 07FF |   GPIOB    |
| 0x4000 0400 - 0x4000 07FF |    TIM3    |

13.3.9 PWM mode

13.4.10
 TIMx counter (TIMx_CNT)
Address offset: 0x24
Bits 31:16 CNT[31:16]: High counter value (on TIM2 and TIM5).
Bits 15:0 CNT[15:0]: Counter value

13.4.11
 TIMx prescaler (TIMx_PSC)
Address offset: 0x28
Bits 15:0 PSC[15:0]: Prescaler value
The counter clock frequency CK_CNT is equal to fCK_PSC / (PSC[15:0] + 1).
PSC contains the value to be loaded in the active prescaler register at each update event
(including when the counter is cleared through UG bit of TIMx_EGR register or through
trigger controller when configured in “reset mode”).

13.4.12
TIMx auto-reload register (TIMx_ARR)
Address offset: 0x2C
Bits 15:0
ARR[15:0]: Auto-reload value
ARR is the value to be loaded in the actual auto-reload register.



---
## Metadata
Sources:
1. RM0368 Reference Manual

Tags: #project #reference 