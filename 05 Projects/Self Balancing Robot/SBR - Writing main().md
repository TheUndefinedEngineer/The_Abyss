*05-05-2026* 

## Task 1 - Led blinking

**Step 1:** Include `stdint.h` library.

**Step 2:** Find boundary address in the register boundary address in RM0368 Section - 2.3

|    Boundary addresses     | Peripheral |
| :-----------------------: | :--------: |
| 0x4002 3800 - 0x4002 3BFF |    RCC     |
| 0x4002 0800 - 0x4002 0BFF |   GPIOC    |
> [!question] Why GPIOC?
> PC13 pin linked to an inbuilt LED on STM32F401CCU6 which makes starting point easier.

**Step 3:** Create a pointer in main.c to access the register and set bits.
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

Set bit 2 to 1 to enable GPIOCEN - `IO port C clock enable`
```c
*RCC_AHB1ENR |= (1 << 2);
```



---
## !
Sources:
1. 

Tags: