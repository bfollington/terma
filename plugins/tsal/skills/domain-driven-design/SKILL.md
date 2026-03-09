---
name: domain-driven-design
description: Applies domain-driven design (DDD) principles to define entities, value objects, and aggregates; map bounded contexts; enforce ubiquitous language; and create visualizations (Mermaid, Graphviz/DOT, ASCII) to communicate domain structure. Draws on Rich Hickey's data-oriented design and Scott Wlaschin's type-driven design to make illegal states unrepresentable and model workflows as explicit data transformations. Use when working on DDD, domain-driven design, entity modeling, aggregate design, value objects, bounded contexts, or event modeling — including designing types, modeling business domains, refactoring domain logic, resolving naming inconsistencies, or ensuring domain consistency across a codebase.
---

# Domain-Driven Design

## Overview

This skill provides guidance for domain modeling based on Rich Hickey's data-oriented design principles and Scott Wlaschin's type-driven design approach. Focus on building systems that make illegal states unrepresentable, prioritize data and transformations over objects and methods, and establish a ubiquitous language that bridges technical implementation and business domain.

## Core Principles

### Rich Hickey's Data-Oriented Design

- **Separate concerns**: Decouple policy from mechanism, data from behavior, when-it-happens from what-happens
- **Data as pure facts**: Model the domain using plain data structures; functions transform data, data does not execute behavior
- **Immutable values**: Use values to represent facts — they enable local reasoning and can be freely shared
- **Decomplect**: Identify what is truly essential vs. incidental; question whether tangled concerns are actually related

### Scott Wlaschin's Type-Driven Design

- **Make illegal states unrepresentable**: Use sum types for mutually exclusive states; avoid primitive obsession; model optionals explicitly
- **Workflows as transformations**: Model business rules as functions — `Input → Process → Output`; separate validation from business logic
- **Railway-oriented programming**: Model success/failure explicitly with Result types; chain fallible operations with bind/flatMap
- **Types as documentation**: Use newtype wrappers for semantic clarity (`UserId`, `EmailAddress`); let the type system guide API design

## DDD Building Blocks

### Entities vs Value Objects

**Decision Guide:**
- Ask: Do domain experts refer to this by ID/name, or does it change over time while maintaining identity? → **Entity**
- Ask: Can I replace it with an equivalent copy? Does only the value matter, not who it is? → **Value Object** (immutable, no unique identifier)

### Aggregates and Aggregate Roots

**Rules:**
- External references go only to the aggregate root (use ID references)
- Root enforces all invariants for the entire aggregate
- Transactions don't cross aggregate boundaries (use eventual consistency)
- Keep aggregates small for better performance and scalability

**When NOT to create an aggregate:**
- Objects can be modified independently
- No shared invariants requiring transactional consistency
- Different objects have different lifecycles

### Bounded Contexts

**When modeling:**
- Identify which bounded context you're in — ubiquitous language is only ubiquitous *within* a context ("Customer" in Sales may differ from "Customer" in Shipping)
- Make context boundaries explicit in code structure (separate modules/namespaces)
- Use anti-corruption layers when integrating across contexts
- Document relationships between contexts (context map)

### Domain Events

- Named in past tense (OrderPlaced, PaymentProcessed, UserRegistered)
- Immutable facts that domain experts care about
- Decouple domain logic, enable eventual consistency between aggregates, integrate bounded contexts, support event sourcing

### Repositories

- Operate at aggregate boundaries (load/save whole aggregates)
- Provide lookup by ID; hide database implementation details
- Return domain entities, not database rows

## Domain Modeling Workflow

### 1. Discover the Ubiquitous Language

**Action Items:**
- List nouns (entities, value objects) and verbs (operations, events) from the domain
- Document domain terms with precise definitions
- Identify synonyms and resolve ambiguity
- Ask: What does the business call this? What are the boundaries of this concept?

**Output Format:**
```markdown
**Term** (Type: Entity/ValueObject/Event/Command)
- Definition: [Clear, domain-expert-approved definition]
- Examples: [Concrete examples]
- Invariants: [Rules that must always hold]
```

### 2. Analyze the Existing Domain Model

**Exploration Steps:**
- Identify where domain concepts are currently modeled (types, schemas, tables)
- Map out relationships between domain entities
- Find where business logic lives (services, functions, stored procedures)
- Document implicit rules and constraints
- Note inconsistencies in naming or modeling

**Questions to Answer:**
- What types/classes represent domain concepts?
- What are the invariants? Where are they enforced?
- Which concepts are tangled together that should be separate?
- Are there phantom types or states that shouldn't exist?

### 3. Identify Inconsistencies and Smells

**Naming Inconsistencies**
- Same concept with different names (User vs Account vs Customer)
- Different concepts with same name (Order as entity vs Order as command)
- Technical names bleeding into domain language (DTO, DAO suffixes)

**Structural Problems**
- Illegal states being representable (e.g., `status: "approved" | "rejected"` with separate `approved_at` and `rejected_at` fields that can both be set)
- Primitive obsession (strings for email, numbers for money)
- Optional fields that are actually required in certain states
- Null/undefined used to represent multiple distinct states

**Complected Concerns**
- Domain logic mixed with infrastructure (DB access in business logic)
- Multiple responsibilities in one type/module
- Temporal coupling (must call A before B or system breaks)

**Missing Concepts**
- Domain concepts that exist in conversations but not in code
- Implicit states that should be explicit
- Business rules enforced through comments or conventions rather than types

### 4. Design the Domain Model

**Type Design:**
- Create sum types for mutually exclusive states:
  ```
  type PaymentStatus =
    | Pending
    | Approved { approvedAt: Timestamp, approvedBy: UserId }
    | Rejected { rejectedAt: Timestamp, reason: string }
  ```
- Use product types to ensure all required data is present
- Create semantic wrappers for primitives:
  ```
  type EmailAddress = EmailAddress of string  // with validation
  type Money = { amount: Decimal, currency: Currency }
  ```

**Data Modeling:**
- Start with the data shape; what are the facts?
- Use immutable values for facts that don't change
- Model state transitions explicitly
- Separate identity from attributes
- Consider: what varies together? What varies independently?

**Workflow Modeling:**
- Model each business workflow as a clear pipeline:
  ```
  ValidateInput → ExecuteBusinessLogic → HandleResult → Persist → Notify
  ```
- Identify decision points and model them explicitly
- Separate pure business logic from effects (IO, time, randomness)
- Use clear function signatures that document intent

### 5. Build and Maintain Ubiquitous Language

**Consistency Rules:**
- Use identical terminology in code, documentation, conversations, and UI
- When domain language changes, update all representations
- Avoid technical jargon in domain code (no "factory", "manager", "handler" unless domain terms)
- Resist the temptation to rename domain concepts for technical convenience

**Code Conventions:**
- Domain types should mirror domain language exactly
- Function names should use domain verbs
- Module boundaries should follow domain boundaries
- Comments should explain domain rules, not implementation details

### 6. Visualize the Domain Model

**Mermaid for Relationships:**
```mermaid
classDiagram
    Order --> Customer
    Order --> OrderLine
    OrderLine --> Product
    Order --> PaymentStatus

    class Order {
        +OrderId id
        +CustomerId customerId
        +List~OrderLine~ lines
        +PaymentStatus status
    }

    class PaymentStatus {
        <<enumeration>>
        Pending
        Approved
        Rejected
    }
```

**Mermaid for Workflows:**
```mermaid
graph LR
    A[Receive Order] --> B{Valid?}
    B -->|Yes| C[Calculate Total]
    B -->|No| D[Return Validation Error]
    C --> E[Process Payment]
    E --> F{Payment Success?}
    F -->|Yes| G[Fulfill Order]
    F -->|No| H[Cancel Order]
```

**Mermaid for State Transitions:**
```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Submitted: submit()
    Submitted --> Approved: approve()
    Submitted --> Rejected: reject()
    Approved --> Fulfilled: fulfill()
    Fulfilled --> [*]
    Rejected --> [*]
```

**Graphviz/DOT for Complex Relationships:**
```dot
digraph domain {
    rankdir=LR;
    node [shape=box];

    Customer -> Order [label="places"];
    Order -> OrderLine [label="contains"];
    OrderLine -> Product [label="references"];
    Order -> Payment [label="requires"];
    Payment -> PaymentMethod [label="uses"];
}
```

**ASCII for Quick Sketches:**
```
Customer
  └─> Order (1:N)
       ├─> OrderLine (1:N)
       │    └─> Product
       └─> Payment (1:1)
            └─> PaymentMethod
```

**When to Use Each:**
- **Mermaid classDiagram**: Entity relationships and type structures
- **Mermaid graph/flowchart**: Business workflows and decision trees
- **Mermaid stateDiagram**: State transitions and lifecycle
- **Graphviz/DOT**: Complex dependency graphs, module boundaries
- **ASCII**: Quick sketches during discussion, simple hierarchies

## Domain Modeling Anti-Patterns

| Anti-Pattern | Symptom | Solution |
|---|---|---|
| **Anemic Domain Model** | Data structures with getters/setters; all logic in separate services | Keep data as data; put related transformations in the same module but separate from data definition |
| **Entity Services** | Classes like `UserService`, `OrderManager`, `ProductFactory` | Name functions after domain operations: `approveOrder`, `cancelSubscription`, `calculateDiscount` |
| **Primitive Obsession** | String for email, number for money, boolean flags for states | Create semantic types with validation |
| **Accidental Complexity** | Complex abstractions or design patterns without clear domain benefit | Simplify; prefer composition over inheritance; avoid premature abstraction |
| **Hidden Temporal Coupling** | Must call methods in specific order or system breaks | Make workflow explicit; use types to enforce valid transitions |
| **Boolean Blindness** | Multiple boolean flags to represent states (`isApproved`, `isActive`, `isDeleted`) | Use sum types for mutually exclusive states |

## Contextualizing Within Existing Models

When adding to or changing an existing domain model:

1. **Map Current State**: Document existing types, relationships, and patterns
2. **Identify Affected Concepts**: Which existing concepts does this change touch?
3. **Check Consistency**: Does new design follow existing patterns? If not, why?
4. **Assess Impact**: What breaks if we make this change?
5. **Migration Path**: How do we evolve from current to desired state?
6. **Update Ubiquitous Language**: Ensure all usage points are updated
7. **Visualize Before/After**: Create diagrams showing current and proposed models

**Key Questions:**
- Does this change align with existing domain boundaries?
- Are we using consistent terminology?
- Does this introduce new concepts or reuse existing ones?
- Are we fixing an inconsistency or introducing a new one?
- Can we make this change incrementally?

## Checklist for Domain Modeling

**Language & Communication:**
- [ ] All domain concepts are named using ubiquitous language
- [ ] Domain glossary is updated with new/changed terms
- [ ] All code, docs, and conversations use identical terminology
- [ ] Bounded context is clearly identified and documented

**Type Design:**
- [ ] Types make illegal states unrepresentable
- [ ] No primitive obsession; semantic types are used appropriately
- [ ] Entities have clear identity; value objects are immutable
- [ ] Sum types used for mutually exclusive states

**Domain Logic:**
- [ ] Business rules are explicit and testable
- [ ] Data and behavior are appropriately separated
- [ ] Workflows are modeled as clear data transformations
- [ ] Domain logic is pure (no side effects)
- [ ] Temporal coupling is eliminated or made explicit

**Aggregates & Boundaries:**
- [ ] Aggregate boundaries are explicit
- [ ] Aggregates enforce their invariants
- [ ] External references to aggregates use IDs only
- [ ] Aggregates are kept small and focused
- [ ] Transactional boundaries are appropriate

**Consistency & Integration:**
- [ ] Inconsistencies with existing model are resolved or documented
- [ ] Cross-aggregate consistency strategy is defined (transactional vs eventual)
- [ ] Domain events are used for important occurrences
- [ ] Integration between bounded contexts uses anti-corruption layers

**Documentation:**
- [ ] Visualization diagrams clearly communicate the design
- [ ] Key decisions and invariants are documented
- [ ] Context map shows relationships between bounded contexts

## Resources

### references/

This skill includes reference documentation for deeper exploration:

- **ddd_foundations_and_patterns.md**: Eric Evans' foundational DDD concepts (entities, value objects, aggregates, bounded contexts, repositories, domain events), Martin Fowler's Ubiquitous Language guidance, and practical Clojure/functional patterns. Essential reading for understanding DDD building blocks and how to apply them.

- **rich_hickey_principles.md**: Core concepts from Rich Hickey's talks including Simple Made Easy, Value of Values, and The Language of the System. Focus on data-oriented design, simplicity, decomplecting, and the power of immutable values.

- **wlaschin_patterns.md**: Scott Wlaschin's type-driven design patterns, domain modeling recipes, functional architecture guidance, and railway-oriented programming. Emphasis on making illegal states unrepresentable and designing with types.

- **visualization_examples.md**: Comprehensive examples of Mermaid, Graphviz, and ASCII diagram patterns for domain modeling. Includes entity relationships, workflows, state machines, aggregate boundaries, and bounded context maps.

Load these references when deeper context is needed on specific principles or patterns.
