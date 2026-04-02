*31-03-2026* 

**What a union is?**
A `union` is a type that lets multiple members share the same block of memory. Unlike a `struct` where each member has its own storage, all members of a `union` start at offset 0 and overlap completely.

```c
union my_union {
    int    a;      // 4 bytes
    float  b;      // 4 bytes
    char   c[16];  // 16 bytes
};
// sizeof = 16, not 24
```

**The one-at-a-time rule:**
At any moment, only one member holds a meaningful value. Writing to `a` puts bytes at offset 0. Writing to `b` puts different bytes at the same offset — `a` is now garbage. Reading from a member you didn't write last is **undefined behaviour** in C.

**The discriminated union pattern:**
Since the union itself doesn't track which member is active, pair it with a tag — usually an `int` or `enum` — wrapped in a `struct`:

```c
typedef enum { TYPE_INT, TYPE_FLOAT, TYPE_STR } tag_t;

typedef struct {
    tag_t tag;           // tells which member is valid
    union {
        int   i;
        float f;
        char  s[16];
    } value;
} variant_t;
```

Then check the tag before reading:

```c
void print_variant(variant_t *v) {
    switch (v->tag) {
        case TYPE_INT:   printf("%d\n",   v->value.i); break;
        case TYPE_FLOAT: printf("%f\n",   v->value.f); break;
        case TYPE_STR:   printf("%s\n",   v->value.s); break;
    }
}
```

This is essentially how higher-level languages implement sum types / tagged unions / `enum` variants with data.

**Common use cases:**
- **Type-flexible buffers** — one buffer that can hold different message formats depending on a header field (the QNX pulse/message case)
- **Type punning** — reading the raw bytes of one type as another (e.g. inspecting the bit pattern of a `float` as a `uint32_t`). Technically only safe via `memcpy` in strict C, but union-based punning is widely accepted
- **Memory-efficient variants** — when you need to store one of several possible types but want to avoid heap allocation (parsers, interpreters, expression trees)
- **Hardware register mapping** — accessing a register both as a full word and as individual bit fields

**Size and alignment:**
The compiler sizes the union to fit its largest member, then pads to satisfy the strictest alignment requirement among all members. So if you have a `char` and a `double` in a union, it will be 8 bytes — not 1.


---
## !
Sources:
1. https://youtu.be/oySsPUDr35U?si=gcKmpmNFazmbBjoe

Tags: #concept 