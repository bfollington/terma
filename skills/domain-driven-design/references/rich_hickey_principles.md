# Rich Hickey's Design Principles

This reference compiles core concepts from Rich Hickey's talks and writings on software design, with focus on simplicity, data-orientation, and decomplecting.

## Simple Made Easy

**Talk:** "Simple Made Easy" (Strange Loop 2011)

### Definitions

**Simple** (opposite: Complex)
- From "simplex" - one fold/braid
- Objective measure: few interleaved concepts
- About lack of interleaving, not cardinality
- Can have many simple things (like individual strands)

**Easy** (opposite: Hard)
- Near at hand, familiar, within capability
- Subjective: varies by person, time, and context
- About convenience and familiarity, not inherent quality

### Key Insight: Simple != Easy

Making something familiar (easy) doesn't make it simple. Choosing familiar constructs that are complex makes systems harder to understand and change over time.

**Trade-off:** Simple may be unfamiliar (initially harder), but pays dividends in comprehension and maintainability.

### Complecting (Interleaving/Braiding)

Complecting is the act of entwining/braiding things together. Once complected:
- Cannot reason about parts independently
- Cannot change one without affecting others
- Cannot reuse parts separately
- Difficult to understand cause and effect

**Examples of Complecting:**
- State and identity complected in mutable objects
- Value and time complected in variables
- Syntax and semantics in many languages
- Policy and mechanism in frameworks

### Simple vs Complex Constructs

| Simple | Complex |
|--------|---------|
| Values | State, Objects |
| Functions | Methods (tied to class) |
| Namespaces | Hierarchical namespaces |
| Data | Objects with behavior |
| Declarative data | Imperative code |
| Rules | Conditional logic |
| Consistency | Eventual consistency |
| Queues | Actors (complect what and how) |

### Making Things Simple

**Strategies:**
1. **Choose simple constructs** - Prefer inherently simple building blocks
2. **Design by subtraction** - Remove, don't add
3. **Separate concerns** - Identify what is truly independent
4. **Use abstraction wisely** - Draw boundaries at natural seams

**Questions to Ask:**
- What is complected here?
- Can these concerns exist independently?
- Am I braiding together things that could be separate?
- Will I be able to change this later?

## The Value of Values

**Talk:** "The Value of Values" (JaxConf 2012)

### What is a Value?

A value is an immutable magnitude, quantity, or number:
- The number 42
- The string "hello"
- The date 2024-01-15
- A tuple/record of values

**Crucially:** Values don't change. "Changing a value" is nonsense (like "changing the number 42").

### Properties of Values

**Immutable**
- Never change, ever
- No notion of time built in
- Can be freely shared without concern

**Semantically Transparent**
- Same value everywhere, always
- No hidden context or identity
- Can be compared for equality directly

**Language Independent**
- 42 is 42 in any language
- Can be transmitted, stored, compared across boundaries

### Values Enable Local Reasoning

Because values don't change:
- Can reason about code by substitution
- No spooky action at a distance
- No defensive copying needed
- Equality is simple and meaningful

### Facts are Values

In domain modeling, facts about the world are values:
- "Order #123 was placed on 2024-01-15"
- "User's email is user@example.com as of yesterday"
- "The price was $42.00 when we recorded it"

**Key Insight:** Facts don't change. New facts may supersede old facts, but old facts remain true about the past.

### Identity vs State

**Identity**
- A stable logical entity (e.g., "User #42")
- Persists through time

**State**
- Value of an identity at a point in time
- "User #42's email address was X on Monday"

**Traditional OOP Problem:** Conflates identity and state in mutable objects. Changing state loses history; can't compare past and present.

**Value-Based Approach:**
- Identity: stable reference
- State: succession of immutable values over time
- Can compare any two states
- Can maintain history naturally

### Memory is Not a Place

Traditional view: Memory is a place where values live and get changed.

Value-oriented view: Memory is a storage mechanism for values. "Updating" means associating a new value with a name; old value unchanged.

**Benefits:**
- Retain history
- Compare snapshots
- Simpler concurrency (values never change)
- Undo/redo naturally

### Applying Values to Domain Modeling

**Model facts, not objects:**
- Don't: `user.setEmail("new@example.com")` (destroys history)
- Do: `events.append({type: "EmailChanged", userId: 42, newEmail: "new@example.com", timestamp: now})`

**Use persistent data structures:**
- Immutable collections that share structure
- Efficient "updates" that create new versions
- All versions remain accessible

**Separate identity from state:**
- Identity: stable reference (ID, key)
- State: series of immutable values
- Functions: transformations from state to state

## Decomplecting

### Separating Concerns

**Not just "separation of concerns" but identifying what CAN be separated:**

Real separation requires:
1. Components have clear, independent purpose
2. Components can be understood in isolation
3. Components can be changed without affecting others
4. Components can be reused in different contexts

### Common Complections to Separate

**Value and Time**
- Complected: Mutable variables (value changes over time)
- Separated: Immutable values + explicit time/version

**What and How**
- Complected: Imperative code (what you want mixed with how to get it)
- Separated: Declarative specification + separate execution strategy

**What and When**
- Complected: Synchronous calls (what to do tied to when it happens)
- Separated: Queues, streams (what is independent of when)

**What and Who**
- Complected: Methods (what you can do tied to who you are / what class)
- Separated: Functions (what you can do independent of caller)

**Mechanism and Policy**
- Complected: Frameworks that dictate both structure and behavior
- Separated: Libraries/functions (mechanism) + application code (policy)

**Domain and Infrastructure**
- Complected: Business logic mixed with DB access, HTTP, etc.
- Separated: Pure domain functions + separate persistence/transport layer

### Process for Decomplecting

1. **Identify the Complection**
   - What seems unnecessarily tangled?
   - What can't I change independently?

2. **Find the Seams**
   - Where do concerns actually divide?
   - What's essential vs. incidental?

3. **Factor Apart**
   - Create separate constructs for separate concerns
   - Use composition to recombine when needed

4. **Validate Independence**
   - Can each part be understood alone?
   - Can each part be tested alone?
   - Can each part be reused elsewhere?

## Data Orientation

**Talks:** "The Language of the System" (Clojure/conj 2012), "Spec-ulation" (Clojure/conj 2016)

### Data > Objects

**Objects:**
- Complect data, behavior, and identity
- Hide information behind APIs
- Create proprietary representations
- Require learning specific APIs

**Data:**
- Open, inspectable, generic
- Can use common tools (map, filter, reduce)
- Self-describing
- Easier to transmit, store, and reason about

### Generic Data Structures

Prefer generic collections (maps, vectors, sets) over custom classes when:
- Data is primarily informational (facts, records, events)
- Behavior is not identity-specific
- Multiple systems/components will interact with the data

**Benefits:**
- Unified tools and functions work across all data
- Easy to extend with new fields
- Easy to serialize and transmit
- Easy to inspect and debug

### Information vs. Mechanism

**Information:**
- Facts about the domain
- Should be data
- Open and accessible

**Mechanism:**
- How things are computed or achieved
- Can be functions/code
- Encapsulated implementation details

**Anti-pattern:** Hiding domain information behind abstraction barriers.

### Systems are Data Flows

Model systems as data flowing through transformations:
1. Receive data (events, requests)
2. Transform data (functions)
3. Produce data (responses, events, state changes)

Each stage: data in → function → data out.

**Benefits:**
- Easy to test (data in, data out)
- Easy to compose (output of one = input of another)
- Easy to reason about (trace data flow)
- Easy to parallelize (data is immutable)

## Language of the System

**Talk:** "The Language of the System" (Clojure/conj 2012)

### Systems Communicate with Data

When components/services communicate, they exchange data. The format and semantics of that data IS the interface.

**Don't:**
- Send proprietary objects
- Rely on shared class definitions
- Use binary formats without schema

**Do:**
- Send data (maps, records)
- Use self-describing formats (JSON, EDN, Transit)
- Version schemas explicitly

### Accretion, Not Breaking Changes

**Growth Strategies:**

**Accretion (Good):**
- Add new fields (optional)
- Add new types/variants
- Extend enums with new cases
- Provide additional operations

**Breaking Changes (Bad):**
- Remove fields
- Rename fields
- Change types
- Remove operations

**Requiring (Neutral):**
- Make optional things required
- Add constraints
- Acceptable if versioned

### Versioning

When breaking changes are necessary:
- Create a new version (v2, v3)
- Support both old and new simultaneously
- Allow consumers to migrate at their pace
- Eventually deprecate old versions

**Never:** Change meaning of existing version.

## Applying to Domain Modeling

### Modeling Domain Data

**Prefer:**
- Plain data structures for domain entities
- Immutable records for domain facts
- Generic collections over custom containers
- Functions that transform domain data

**Avoid:**
- Mutable domain objects
- Behavior attached to entities
- Getters/setters (ceremony without benefit)
- Hidden state

### Example: Order Domain

**Complex (Complected):**
```typescript
class Order {
  private lines: OrderLine[] = [];
  private status: Status = Status.Draft;

  addLine(product: Product, qty: number) {
    this.lines.push(new OrderLine(product, qty));
  }

  submit() {
    if (this.lines.length === 0) throw new Error("Empty order");
    this.status = Status.Submitted;
  }
}
```

**Simple (Decomplected):**
```typescript
type Order = {
  id: OrderId;
  customerId: CustomerId;
  lines: readonly OrderLine[];
  status: OrderStatus;
  createdAt: Timestamp;
};

function addLine(order: Order, line: OrderLine): Order {
  return { ...order, lines: [...order.lines, line] };
}

function submitOrder(order: Order): Result<Order, ValidationError> {
  if (order.lines.length === 0) {
    return Err({ type: "EmptyOrder" });
  }
  return Ok({ ...order, status: { type: "Submitted", submittedAt: now() } });
}
```

**Why simpler:**
- Data and functions separate
- Immutable values
- Explicit about time (createdAt, submittedAt)
- No hidden state
- Easy to test, inspect, transmit

## Key Takeaways

1. **Simplicity is objective** - Measured by lack of interleaving, not familiarity
2. **Values don't change** - Model facts as immutable values; identity is separate
3. **Data is better than objects** - Generic, open data beats proprietary encapsulation
4. **Separate concerns rigorously** - Identify what can truly be independent
5. **Accrete, don't break** - Grow systems by adding, not changing
6. **Systems are data flows** - Model as transformations of immutable data

When domain modeling, constantly ask:
- What have I complected here?
- Can I use values instead of mutable state?
- Can I use data instead of objects?
- What can be separated?
- Am I making a breaking change, or accreting?
