*04-05-2026* 
## The two uses of `extern`

`extern` is used in two completely different situations in C. In bare-metal programming you need to understand **both**.

|Use|What it means|
|---|---|
|`extern` on a regular variable|"This variable is defined in another `.c` file — don't allocate storage here, just reference it"|
|`extern` on a linker symbol|"This name is not a C variable at all — it is an address defined by the linker script"|

---
## Use 1 — Sharing variables across `.c` files

```c
/* file_a.c */
int counter = 0;       // definition — storage allocated here

/* file_b.c */
extern int counter;    // declaration — "counter lives somewhere else, trust me"
counter++;             // works — linker connects them
```

`extern` here tells the compiler: "don't create storage for `counter`, the linker will find it in another object file." Standard C, nothing special.

---
## Use 2 — Accessing linker script symbols (bare-metal)

This is the one that trips people up.

In your linker script you define symbols like:
```ld
_sdata = .;    /* just an address — NOT a variable */
_edata = .;
_etext = .;
_sbss  = .;
_ebss  = .;
```

These are **not variables**. They have no storage. They are just names the linker gives to addresses. To use them in C you declare them with `extern`:
```c
extern uint32_t _sdata;
extern uint32_t _edata;
extern uint32_t _etext;
extern uint32_t _sbss;
extern uint32_t _ebss;
```

---
## The critical rule — always take the address

> [!important] When using a linker symbol in C, **always use `&symbol`**, never use `symbol` directly.

```c
// WRONG — reads the VALUE at that address (garbage/undefined)
uint32_t size = _edata - _sdata;

// CORRECT — uses the ADDRESS itself as the value
uint32_t size = &_edata - &_sdata;
```

### Why?
A linker symbol is a **name for an address**. The symbol itself IS the address. When you write `_sdata` in C, the compiler treats it like a regular variable and fetches the value stored at that address. When you write `&_sdata`, you get the address — which is exactly what the linker assigned.

Think of it this way:
```
Linker script:   _sdata = 0x20000000

In C:
  _sdata   → "go to address 0x20000000, read the bytes there" → garbage
  &_sdata  → "give me the address 0x20000000 itself"         → correct
```

---
## How it looks in Reset_Handler

```c
// These declarations tell the compiler:
// "these names exist — the linker will resolve their addresses"
extern uint32_t _sdata;   // start of .data in SRAM
extern uint32_t _edata;   // end of .data in SRAM
extern uint32_t _etext;   // end of .text in Flash = start of .data image in Flash
extern uint32_t _sbss;    // start of .bss in SRAM
extern uint32_t _ebss;    // end of .bss in SRAM

void Reset_Handler(void) {
    uint32_t size = &_edata - &_sdata;  // size of .data section in bytes

    uint8_t *pDst = (uint8_t*)&_sdata; // where .data runs (SRAM)
    uint8_t *pSrc = (uint8_t*)&_etext; // where .data is stored (Flash)
    // ...
}
```

The `uint32_t` type in the `extern` declaration is mostly a convention — what matters is that you always access these via `&`. Some codebases use `extern uint8_t` or even `extern char`, all equally valid since the type is never used directly.

---
## Why not just use `#define` with the raw address?

```c
// you could hardcode:
#define SDATA_START  0x20000000U
#define SDATA_END    0x20000040U

// but then:
// - you must update the C file every time the linker script changes
// - if .data grows, you have to recalculate manually
// - mismatch between linker script and C = silent corruption at boot
```

With `extern` linker symbols, the linker always provides the correct address automatically regardless of how your code grows. Zero maintenance, zero mismatch.

---
## Type doesn't matter — the address does

```c
// all of these are equivalent for linker symbols:
extern uint8_t  _sdata;
extern uint16_t _sdata;
extern uint32_t _sdata;
extern char     _sdata;

// because you always use &_sdata, never _sdata
// &_sdata is always the same address regardless of type
```

The type only affects what the compiler thinks `_sdata` holds — but since you never dereference it directly, it doesn't matter. `uint32_t` is conventional because the linker script deals in 4-byte aligned words.

---
## Common pattern in startup files

```c
// startup.c
extern uint32_t _etext;
extern uint32_t _sdata;
extern uint32_t _edata;
extern uint32_t _sbss;
extern uint32_t _ebss;

void Reset_Handler(void) {
    // 1. copy .data from Flash → SRAM
    uint32_t *src = &_etext;
    uint32_t *dst = &_sdata;
    while (dst < &_edata) {
        *dst++ = *src++;
    }

    // 2. zero .bss
    dst = &_sbss;
    while (dst < &_ebss) {
        *dst++ = 0;
    }

    // 3. run
    main();
}
```

Note this version uses `uint32_t*` pointers directly (without casting to `uint8_t*`) — this works cleanly when `ALIGN(4)` is used in the linker script, making both source and destination word-aligned.

---
## Summary

|Concept|Key point|
|---|---|
|`extern` on a C variable|"Defined elsewhere, donker allocate storage"|
|`extern` on a linker symbol|"This name is an address from the linker script"|
|Always use `&symbol`|The address IS the value — never dereference directly|
|Type is convention|`uint32_t` is typical but the type itself doesn't matter|
|Why not `#define`?|Linker symbols auto-update as code grows; hardcoded addresses don't|


---
## !
Sources:
1. 

Tags: #concept #reference 