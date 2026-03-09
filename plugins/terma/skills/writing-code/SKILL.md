---
name: writing-good-code
description: Provides opinionated, Rich Hickey-inspired coding principles and style guidance for writing clean, readable, and intentional code. Use when writing new code, refactoring existing code, reviewing code quality, choosing between functions and classes, structuring modules, or applying functional and data-first programming principles — especially when prioritising simplicity, types-first design, and small focused routines over object-oriented patterns.
---

# Writing good code

- prefer functions over classes unless managing resources
- let the types and signatures do the talking
- prefer flat code, small focused routines
- the program should read like the story of what it does
- the structure and name of the modules is critical
- write the types first, then the functions, then the tests, then the integrations
- make the smallest change possible or leave the code cleaner than you found it
- rigor and intentionality upfront is worth it

write code like Rich Hickey

Read and apply the guidance from @../../lib/code-style.md

---

## Concrete examples

### Prefer functions over classes

**Bad** — a class used purely for bundling stateless behaviour:
```python
class OrderCalculator:
    def calculate_total(self, items):
        return sum(item.price for item in items)

    def apply_discount(self, total, rate):
        return total * (1 - rate)
```

**Good** — plain functions; no hidden state, easier to test and compose:
```python
def calculate_total(items):
    return sum(item.price for item in items)

def apply_discount(total, rate):
    return total * (1 - rate)
```

Use a class only when it genuinely manages a resource lifecycle (e.g., a database connection, a file handle).

---

### Write the types first

Start by defining your data shapes before writing any logic. This forces clarity about what the program actually operates on.

```typescript
// 1. Types first
type OrderId = string;
type Money = { amount: number; currency: string };
type LineItem = { productId: string; quantity: number; unitPrice: Money };
type Order = { id: OrderId; items: LineItem[]; placedAt: Date };

// 2. Then the functions — signatures are self-documenting
function orderTotal(order: Order): Money { ... }
function applyDiscount(total: Money, ratePercent: number): Money { ... }

// 3. Then tests, then integration wiring
```

The types act as executable documentation: a reader knows the domain before reading a single line of logic.

---

### Flat code over nested logic

**Bad** — deeply nested, hard to follow the story:
```python
def process(order):
    if order:
        if order.items:
            for item in order.items:
                if item.in_stock:
                    ship(item)
```

**Good** — early returns keep the happy path flat and readable:
```python
def process(order):
    if not order or not order.items:
        return
    for item in order.items:
        if item.in_stock:
            ship(item)
```

---

### Review checklist

Before submitting or finishing a piece of code, verify it against the core principles:

- [ ] Functions preferred over classes where no resource lifecycle is managed
- [ ] Types / signatures defined first and are self-documenting
- [ ] No unnecessary nesting — early returns used where appropriate
- [ ] Each routine is small and focused on one thing
- [ ] Module names and structure tell the story of the domain
- [ ] Change is the smallest possible; code is no messier than it was found
- [ ] `code-style.md` rules applied (naming, imports, linting)

---

### What `code-style.md` contains

`@../../lib/code-style.md` provides project-specific style rules (naming conventions, import ordering, linting configuration, and language-specific idioms). Always read it before writing or reviewing code in this project — it is the authoritative source for decisions not covered by the general principles above.
