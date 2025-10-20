# Scott Wlaschin's Type-Driven Design Patterns

This reference compiles patterns and principles from Scott Wlaschin's work on domain modeling, functional architecture, and type-driven design.

## Core Philosophy

**"Make Illegal States Unrepresentable"**

Use the type system to eliminate entire categories of bugs at compile time. If a state shouldn't exist in your domain, make it impossible to construct.

## Domain Modeling Made Functional

### Understanding the Domain

**Key Questions:**
1. What are the inputs and outputs?
2. What can happen? (scenarios, workflows)
3. What can go wrong? (errors, edge cases)
4. What are the business rules and constraints?
5. What are the invariants that must always hold?

**Process:**
1. Talk to domain experts using their language
2. Document workflows as transformations
3. Identify the things (nouns) and actions (verbs)
4. Model the lifecycle and state transitions
5. Capture rules and constraints as types

### Workflows as Pipelines

Model business workflows as data transformation pipelines:

```
Input → Validate → Execute Business Logic → Persist → Output
```

Each step:
- Takes data as input
- Performs a transformation
- Produces data as output
- May fail (use Result types)

**Benefits:**
- Clear separation of concerns
- Easy to test each step
- Easy to compose steps
- Makes the happy path obvious

### Example: Order Placement Workflow

```
UnvalidatedOrder
  → ValidateOrder
  → ValidatedOrder
  → PriceOrder
  → PricedOrder
  → PlaceOrder
  → PlacedOrderEvent
```

Each arrow is a function. Each type in between represents a distinct state with its own invariants.

## Type-Driven Design

### Making Illegal States Unrepresentable

**Problem:** Optional fields that create invalid combinations

**Bad:**
```typescript
type Order = {
  id: string;
  // Both can be null, or both can be set - illegal!
  approvedAt: Date | null;
  rejectedAt: Date | null;
}
```

**Good:**
```typescript
type Order = {
  id: OrderId;
  status:
    | { type: "Pending" }
    | { type: "Approved"; approvedAt: Date }
    | { type: "Rejected"; rejectedAt: Date };
}
```

Now impossible to be both approved and rejected, or to have dates without corresponding status.

### Constrained Types

Create types that can only hold valid values:

**Bad:** Primitive obsession
```typescript
function createUser(email: string, age: number) { ... }
// Can pass invalid values: createUser("not-an-email", -5)
```

**Good:** Constrained types
```typescript
type EmailAddress = EmailAddress & { __brand: "EmailAddress" };
type Age = Age & { __brand: "Age" };

function createEmailAddress(s: string): Result<EmailAddress, ValidationError> {
  if (isValidEmail(s)) return Ok(s as EmailAddress);
  return Err({ error: "Invalid email format" });
}

function createAge(n: number): Result<Age, ValidationError> {
  if (n >= 0 && n <= 150) return Ok(n as Age);
  return Err({ error: "Age must be between 0 and 150" });
}

function createUser(email: EmailAddress, age: Age) { ... }
// Can only pass validated values!
```

### Single Case Unions (Wrapper Types)

Use wrapper types to give semantic meaning to primitives:

```typescript
type CustomerId = { readonly value: string };
type ProductId = { readonly value: string };
type OrderId = { readonly value: string };

// Now cannot confuse these:
function getCustomer(id: CustomerId): Customer { ... }
// getCustomer(productId) // Type error!
```

**Benefits:**
- Type safety
- Self-documenting code
- Cannot confuse similar primitives
- Compiler catches errors

### Exhaustive Pattern Matching

Use discriminated unions and let the compiler ensure you handle all cases:

```typescript
type PaymentMethod =
  | { type: "CreditCard"; cardNumber: string; cvv: string }
  | { type: "PayPal"; email: EmailAddress }
  | { type: "BankTransfer"; accountNumber: string; routingNumber: string };

function processPayment(method: PaymentMethod): Result<Receipt, PaymentError> {
  switch (method.type) {
    case "CreditCard":
      return processCreditCard(method.cardNumber, method.cvv);
    case "PayPal":
      return processPayPal(method.email);
    case "BankTransfer":
      return processBankTransfer(method.accountNumber, method.routingNumber);
    // If we add a new payment method, compiler will error here
  }
}
```

### States and Transitions

Model entity states explicitly, not as flags:

**Bad:**
```typescript
type Order = {
  isPaid: boolean;
  isShipped: boolean;
  isCancelled: boolean;
  // Can be paid and cancelled? Shipped but not paid?
}
```

**Good:**
```typescript
type Order =
  | { state: "Unpaid"; items: OrderLine[] }
  | { state: "Paid"; items: OrderLine[]; paidAt: Date; paymentMethod: PaymentMethod }
  | { state: "Shipped"; items: OrderLine[]; paidAt: Date; shippedAt: Date; trackingNumber: string }
  | { state: "Cancelled"; reason: string };
```

Now impossible to be in multiple states or to be shipped without being paid.

## Railway-Oriented Programming

### The Problem

Functions that can fail complicate the happy path:

```typescript
function placeOrder(unvalidatedOrder: UnvalidatedOrder) {
  const validatedOrder = validateOrder(unvalidatedOrder);
  if (validatedOrder.isError) return validatedOrder.error;

  const pricedOrder = priceOrder(validatedOrder.value);
  if (pricedOrder.isError) return pricedOrder.error;

  const placedOrder = saveOrder(pricedOrder.value);
  if (placedOrder.isError) return placedOrder.error;

  return placedOrder.value;
}
```

**Problem:** Error handling obscures the happy path.

### Result Type

Model success and failure explicitly:

```typescript
type Result<T, E> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

### Chaining with bind/flatMap

Chain operations that return Results:

```typescript
function placeOrder(unvalidatedOrder: UnvalidatedOrder): Result<PlacedOrder, OrderError> {
  return validateOrder(unvalidatedOrder)
    .flatMap(priceOrder)
    .flatMap(saveOrder);
}
```

**The Railway Metaphor:**
- Two tracks: Success and Failure
- Functions switch from success to failure track on error
- Once on failure track, stay on failure track
- Clear separation: happy path is just composition

### Combining Results

When you need multiple independent validations:

```typescript
function createUser(
  emailStr: string,
  ageNum: number,
  nameStr: string
): Result<User, ValidationErrors> {
  const email = createEmail(emailStr);
  const age = createAge(ageNum);
  const name = createName(nameStr);

  // Collect all errors, not just first
  return combineResults([email, age, name], (email, age, name) => ({
    email,
    age,
    name
  }));
}
```

### Handling Errors at Boundaries

Keep the domain pure; handle effects at edges:

**Inside domain (pure):**
```typescript
function validateOrder(order: UnvalidatedOrder): Result<ValidatedOrder, ValidationError> {
  // Pure validation logic, no IO
}
```

**At boundary (effects):**
```typescript
async function handleOrderRequest(req: Request): Promise<Response> {
  const result = validateOrder(req.body)
    .flatMap(priceOrder)
    .flatMap(saveOrder);  // IO happens here

  if (result.ok) {
    return { status: 200, body: result.value };
  } else {
    return { status: 400, body: { error: result.error } };
  }
}
```

## Designing with Types

### Start with the Types

Before writing any implementation:

1. **Define the types** that represent domain concepts
2. **Define the function signatures** (inputs and outputs)
3. **Implement the functions** (fill in the logic)

**Benefits:**
- Types guide implementation
- Types serve as documentation
- Types catch mismatches early
- Refactoring is safer

### Example: Designing a Discount System

**Step 1: Define domain types**
```typescript
type Product = { id: ProductId; price: Money; category: Category };
type Customer = { id: CustomerId; membershipLevel: MembershipLevel };
type Category = "Electronics" | "Clothing" | "Books";
type MembershipLevel = "Bronze" | "Silver" | "Gold";

type DiscountRule =
  | { type: "Percentage"; percentage: number }
  | { type: "FixedAmount"; amount: Money }
  | { type: "BuyXGetY"; buyQuantity: number; getQuantity: number };

type Discount = {
  rule: DiscountRule;
  applicableTo: Category[];
  minimumMembershipLevel: MembershipLevel | null;
};
```

**Step 2: Define function signatures**
```typescript
function calculateDiscount(
  product: Product,
  quantity: number,
  customer: Customer,
  discounts: Discount[]
): Money;

function findApplicableDiscounts(
  product: Product,
  customer: Customer,
  discounts: Discount[]
): Discount[];

function applyDiscount(
  price: Money,
  quantity: number,
  discount: Discount
): Money;
```

**Step 3: Implement** (signatures guide what's needed)

### Use Types to Model Business Rules

Encode business rules in types:

**Rule:** "An order must have at least one item"

```typescript
type NonEmptyList<T> = {
  head: T;
  tail: T[];
};

type Order = {
  id: OrderId;
  items: NonEmptyList<OrderLine>;  // Cannot be empty!
};
```

**Rule:** "Refunds require a reason if amount exceeds $100"

```typescript
type Refund =
  | { amount: Money; reason: null }  // reason not needed
  | { amount: Money; reason: string };  // reason required

// Factory function enforces rule:
function createRefund(amount: Money, reason: string | null): Refund {
  if (amount.value > 100 && reason === null) {
    throw new Error("Refund over $100 requires a reason");
  }
  return { amount, reason };
}
```

## Functional Architecture Patterns

### Onion/Hexagonal Architecture

**Layers (inside-out):**
1. **Domain** - Pure business logic, no dependencies
2. **Application** - Workflows, orchestration, still pure
3. **Infrastructure** - IO, databases, external services

**Dependency Rule:** Outer layers depend on inner layers, never reverse.

**Domain Layer:**
- Pure functions
- Domain types
- Business rules
- No IO, no frameworks

**Application Layer:**
- Composes domain functions into workflows
- Still mostly pure
- Defines interfaces (ports) for infrastructure

**Infrastructure Layer:**
- Implements ports (adapters)
- Handles IO (database, HTTP, file system)
- Deals with frameworks and libraries

### Dependency Injection via Function Parameters

Pass dependencies as function parameters:

```typescript
// Domain function defines what it needs
function placeOrder(
  validateAddress: (address: Address) => Result<ValidatedAddress, ValidationError>,
  checkInventory: (productId: ProductId) => Promise<boolean>,
  saveOrder: (order: Order) => Promise<Result<void, DbError>>,
  order: UnvalidatedOrder
): Promise<Result<OrderPlaced, OrderError>> {
  // Implementation uses provided functions
}

// At composition root, provide implementations:
const result = await placeOrder(
  addressValidator.validate,
  inventory.check,
  orderRepository.save,
  incomingOrder
);
```

**Benefits:**
- No hidden dependencies
- Easy to test (pass mock functions)
- Explicit about requirements
- No magic or DI container

### Command/Query Separation

**Commands:** Change state, return void or Result<void, Error>
- `placeOrder(order): Result<void, OrderError>`
- `cancelSubscription(id): Result<void, CancellationError>`
- `updateProfile(profile): Result<void, ValidationError>`

**Queries:** Read state, return data, never change state
- `getOrder(id): Option<Order>`
- `findCustomersByEmail(email): Customer[]`
- `getTotalRevenue(): Money`

**Benefits:**
- Clear separation of reads and writes
- Easier to optimize (cache queries)
- Easier to reason about (commands have effects, queries don't)

### Event Sourcing Pattern

Instead of storing current state, store sequence of events:

```typescript
type OrderEvent =
  | { type: "OrderPlaced"; orderId: OrderId; items: OrderLine[]; at: Timestamp }
  | { type: "OrderPaid"; orderId: OrderId; amount: Money; at: Timestamp }
  | { type: "OrderShipped"; orderId: OrderId; trackingNumber: string; at: Timestamp }
  | { type: "OrderCancelled"; orderId: OrderId; reason: string; at: Timestamp };

function applyEvent(state: Order | null, event: OrderEvent): Order {
  switch (event.type) {
    case "OrderPlaced":
      return { id: event.orderId, items: event.items, status: "Placed" };
    case "OrderPaid":
      return { ...state!, status: "Paid" };
    case "OrderShipped":
      return { ...state!, status: "Shipped", trackingNumber: event.trackingNumber };
    case "OrderCancelled":
      return { ...state!, status: "Cancelled", reason: event.reason };
  }
}

function reconstruct(events: OrderEvent[]): Order {
  return events.reduce(applyEvent, null)!;
}
```

**Benefits:**
- Complete history
- Audit trail
- Can replay to any point in time
- Events are facts (immutable)

## Practical Patterns

### Option Type for Missing Values

Don't use null/undefined for domain concepts:

```typescript
type Option<T> = { some: true; value: T } | { some: false };

function findCustomer(id: CustomerId): Option<Customer> {
  // ...
}

// Forces handling:
const result = findCustomer(customerId);
if (result.some) {
  console.log(result.value.name);
} else {
  console.log("Customer not found");
}
```

### Newtype Pattern for Type Safety

Create distinct types from same underlying representation:

```typescript
type UserId = string & { __brand: "UserId" };
type ProductId = string & { __brand: "ProductId" };
type OrderId = string & { __brand: "OrderId" };

// Can't mix up IDs:
function getUser(id: UserId): User { ... }
const productId: ProductId = ...;
// getUser(productId); // Type error!
```

### Builder Pattern for Complex Construction

For complex objects with many fields:

```typescript
class OrderBuilder {
  private order: Partial<Order> = {};

  withCustomer(id: CustomerId): this {
    this.order.customerId = id;
    return this;
  }

  addItem(item: OrderLine): this {
    this.order.items = [...(this.order.items || []), item];
    return this;
  }

  build(): Result<Order, ValidationError> {
    if (!this.order.customerId) return Err({ error: "Customer required" });
    if (!this.order.items?.length) return Err({ error: "Items required" });
    // ... validate all required fields present
    return Ok(this.order as Order);
  }
}

const result = new OrderBuilder()
  .withCustomer(customerId)
  .addItem(item1)
  .addItem(item2)
  .build();
```

### Active Pattern / Parser Pattern

Transform external data into domain types:

```typescript
function parseOrderRequest(json: unknown): Result<UnvalidatedOrder, ParseError> {
  // Parse and validate structure
  if (!isObject(json)) return Err({ error: "Expected object" });
  if (!hasProperty(json, "items")) return Err({ error: "Missing items" });
  // ... more parsing
  return Ok({ items: json.items, customerId: json.customerId });
}

function handleRequest(req: Request): Response {
  return parseOrderRequest(req.body)
    .flatMap(validateOrder)
    .flatMap(placeOrder)
    .match(
      success => ({ status: 200, body: success }),
      error => ({ status: 400, body: { error } })
    );
}
```

## Domain Modeling Recipes

### Recipe: Modeling a Workflow

1. **Name the workflow** using ubiquitous language
2. **Define the input** (unvalidated/raw data)
3. **Define the output** (result of successful execution)
4. **Define errors** (what can go wrong)
5. **Break into steps** (validation, execution, persistence)
6. **Type each intermediate state**
7. **Implement as pipeline**

### Recipe: Modeling State Transitions

1. **List all possible states**
2. **For each state, determine what data is available**
3. **Create a discriminated union type**
4. **Define transition functions** (State → Event → Result<State, Error>)
5. **Ensure illegal transitions are unrepresentable**

### Recipe: Modeling Optional Fields

1. **Ask: Is this really optional in all cases?**
2. **If optional in all cases:** Use Option type
3. **If required in some states, optional in others:** Use discriminated union with separate states
4. **Never** use null/undefined for domain optionality

### Recipe: Modeling Business Rules

1. **Express rule in English**
2. **Identify what makes the rule satisfied**
3. **Use types to enforce:** Constrained types, discriminated unions, or validation functions
4. **Make it impossible to violate:** Better in types than in runtime checks

## Key Takeaways

1. **Use types to make illegal states unrepresentable**
2. **Model workflows as pipelines of data transformations**
3. **Use Result types for operations that can fail**
4. **Keep domain pure, handle effects at boundaries**
5. **Design with types first, implementation second**
6. **Use wrapper types to add semantic meaning**
7. **Separate commands (writes) from queries (reads)**
8. **Model events as immutable facts**
9. **Use Option type instead of null/undefined**
10. **Let the compiler be your friend - exhaustive pattern matching**

When domain modeling, continuously ask:
- What illegal states can I eliminate?
- What can go wrong here?
- Is this type signature telling the truth?
- Can I make this constraint explicit in the type?
- What's the simplest type that captures this domain concept?
