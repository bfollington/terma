# Domain Modeling Visualization Examples

This reference provides comprehensive examples of using Mermaid, Graphviz/DOT, and ASCII diagrams for domain modeling visualization.

## When to Use Each Format

| Format | Best For | Strengths | Limitations |
|--------|----------|-----------|-------------|
| **Mermaid** | Quick diagrams, workflows, state machines | Easy syntax, widely supported, good for communication | Limited layout control |
| **Graphviz/DOT** | Complex relationships, dependency graphs | Powerful layout algorithms, precise control | More verbose syntax |
| **ASCII** | Quick sketches, simple hierarchies, inline docs | Immediately readable in any editor, minimal | Limited visual appeal, simple structures only |

## Mermaid Diagrams

### Class Diagrams for Domain Entities

**Use for:** Showing entity relationships and structure

```mermaid
classDiagram
    Customer "1" --> "*" Order : places
    Order "1" --> "*" OrderLine : contains
    OrderLine "*" --> "1" Product : references
    Order "1" --> "1" PaymentStatus : has

    class Customer {
        +CustomerId id
        +EmailAddress email
        +CustomerName name
        +MembershipLevel level
    }

    class Order {
        +OrderId id
        +CustomerId customerId
        +List~OrderLine~ lines
        +PaymentStatus status
        +Timestamp createdAt
        +calculateTotal() Money
    }

    class OrderLine {
        +ProductId productId
        +Quantity quantity
        +Money unitPrice
        +calculateSubtotal() Money
    }

    class Product {
        +ProductId id
        +ProductName name
        +Money price
        +Category category
    }

    class PaymentStatus {
        <<enumeration>>
        Pending
        Approved
        Rejected
        Refunded
    }
```

**With generics and constraints:**

```mermaid
classDiagram
    class Result~T, E~ {
        <<interface>>
        +isOk() boolean
        +isErr() boolean
        +map(fn) Result~U, E~
        +flatMap(fn) Result~U, E~
    }

    class Ok~T~ {
        +value T
    }

    class Err~E~ {
        +error E
    }

    Result~T, E~ <|-- Ok~T~
    Result~T, E~ <|-- Err~E~
```

### Flowcharts for Business Workflows

**Use for:** Showing decision points and process flow

```mermaid
flowchart TD
    Start([Receive Order Request]) --> Parse[Parse Request]
    Parse --> Valid{Valid Format?}
    Valid -->|No| ReturnError[Return 400 Bad Request]
    Valid -->|Yes| Validate[Validate Business Rules]

    Validate --> Rules{Rules Pass?}
    Rules -->|No| ReturnValidation[Return Validation Errors]
    Rules -->|Yes| CheckInventory[Check Inventory]

    CheckInventory --> InStock{In Stock?}
    InStock -->|No| OutOfStock[Return Out of Stock Error]
    InStock -->|Yes| CalculatePrice[Calculate Price]

    CalculatePrice --> ProcessPayment[Process Payment]
    ProcessPayment --> PaymentOk{Payment Success?}

    PaymentOk -->|No| PaymentError[Return Payment Error]
    PaymentOk -->|Yes| CreateOrder[Create Order Record]

    CreateOrder --> SendConfirmation[Send Confirmation Email]
    SendConfirmation --> End([Return 201 Created])

    ReturnError --> End
    ReturnValidation --> End
    OutOfStock --> End
    PaymentError --> End
```

**Railway-oriented programming pattern:**

```mermaid
flowchart LR
    Input[Unvalidated Order] --> Validate
    Validate --> ValidResult{Result}
    ValidResult -->|Ok| Price[Price Order]
    ValidResult -->|Err| Error1[Validation Error]

    Price --> PriceResult{Result}
    PriceResult -->|Ok| Save[Save Order]
    PriceResult -->|Err| Error2[Pricing Error]

    Save --> SaveResult{Result}
    SaveResult -->|Ok| Notify[Send Notification]
    SaveResult -->|Err| Error3[Database Error]

    Notify --> Success[Order Placed]

    Error1 --> ErrorHandler[Handle Error]
    Error2 --> ErrorHandler
    Error3 --> ErrorHandler
    ErrorHandler --> FailureOutput[Error Response]
```

### State Diagrams for Lifecycle Modeling

**Use for:** Showing valid state transitions

```mermaid
stateDiagram-v2
    [*] --> Draft

    Draft --> Submitted : submit()
    Draft --> Abandoned : timeout()

    Submitted --> UnderReview : startReview()

    UnderReview --> Approved : approve()
    UnderReview --> Rejected : reject()
    UnderReview --> NeedsRevision : requestChanges()

    NeedsRevision --> Submitted : resubmit()
    NeedsRevision --> Abandoned : cancel()

    Approved --> Published : publish()
    Approved --> Archived : archive()

    Rejected --> [*]
    Abandoned --> [*]
    Published --> Archived : archive()
    Archived --> [*]

    note right of UnderReview
        Review must complete
        within 48 hours
    end note
```

**With nested states:**

```mermaid
stateDiagram-v2
    [*] --> Active

    state Active {
        [*] --> Free
        Free --> Trial : startTrial()
        Trial --> Paid : subscribe()
        Trial --> Free : trialExpires()
        Paid --> Free : cancel()

        state Paid {
            [*] --> Monthly
            Monthly --> Annual : upgrade()
            Annual --> Monthly : downgrade()
        }
    }

    Active --> Suspended : suspend()
    Suspended --> Active : reactivate()
    Suspended --> Closed : permanentClose()
    Active --> Closed : closeAccount()
    Closed --> [*]
```

### Sequence Diagrams for Interactions

**Use for:** Showing message flow between components

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Domain
    participant DB
    participant EmailService

    Client->>API: POST /orders
    API->>API: Parse request
    API->>Domain: validateOrder(data)
    Domain-->>API: Result<ValidatedOrder>

    alt validation failed
        API-->>Client: 400 Bad Request
    else validation succeeded
        API->>Domain: priceOrder(validatedOrder)
        Domain-->>API: PricedOrder

        API->>DB: saveOrder(pricedOrder)
        DB-->>API: OrderId

        API->>EmailService: sendConfirmation(orderId)
        EmailService-->>API: Async confirmation

        API-->>Client: 201 Created
    end
```

### Entity Relationship Diagrams

**Use for:** Database schema or aggregate boundaries

```mermaid
erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_LINE : contains
    PRODUCT ||--o{ ORDER_LINE : "ordered in"
    ORDER ||--|| PAYMENT : requires
    PAYMENT ||--|| PAYMENT_METHOD : uses

    CUSTOMER {
        uuid id PK
        string email
        string name
        enum membership_level
        timestamp created_at
    }

    ORDER {
        uuid id PK
        uuid customer_id FK
        enum status
        decimal total
        timestamp created_at
        timestamp updated_at
    }

    ORDER_LINE {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
        decimal unit_price
    }

    PRODUCT {
        uuid id PK
        string name
        decimal price
        enum category
        int stock_quantity
    }

    PAYMENT {
        uuid id PK
        uuid order_id FK
        uuid payment_method_id FK
        decimal amount
        enum status
        timestamp processed_at
    }
```

### Gantt Charts for Project Planning

**Use for:** Timeline and dependency visualization

```mermaid
gantt
    title Domain Model Implementation Timeline
    dateFormat  YYYY-MM-DD
    section Core Types
    Define value objects       :done, types1, 2024-01-01, 3d
    Define entities           :done, types2, after types1, 2d
    Define aggregates         :active, types3, after types2, 3d

    section Validation
    Input validation          :valid1, after types3, 2d
    Business rule validation  :valid2, after valid1, 3d

    section Workflows
    Order placement workflow  :wf1, after valid2, 5d
    Payment workflow         :wf2, after wf1, 4d
    Fulfillment workflow     :wf3, after wf2, 4d

    section Testing
    Unit tests               :test1, after types1, 15d
    Integration tests        :test2, after wf1, 10d
```

## Graphviz/DOT Diagrams

### Complex Dependency Graphs

**Use for:** Module dependencies, complex relationships

```dot
digraph dependencies {
    rankdir=LR;
    node [shape=box, style=rounded];

    // Layers
    subgraph cluster_domain {
        label="Domain Layer";
        style=filled;
        color=lightblue;

        types [label="Domain Types"];
        validation [label="Validation"];
        logic [label="Business Logic"];
    }

    subgraph cluster_application {
        label="Application Layer";
        style=filled;
        color=lightgreen;

        workflows [label="Workflows"];
        commands [label="Commands"];
        queries [label="Queries"];
    }

    subgraph cluster_infrastructure {
        label="Infrastructure Layer";
        style=filled;
        color=lightgrey;

        db [label="Database"];
        http [label="HTTP Client"];
        email [label="Email Service"];
    }

    // Dependencies
    validation -> types;
    logic -> types;
    logic -> validation;

    workflows -> logic;
    workflows -> validation;
    commands -> workflows;
    queries -> workflows;

    workflows -> db [style=dashed, label="port"];
    workflows -> http [style=dashed, label="port"];
    workflows -> email [style=dashed, label="port"];
}
```

### Aggregate Boundaries

**Use for:** DDD aggregates and bounded contexts

```dot
digraph aggregates {
    rankdir=TB;
    node [shape=box];

    subgraph cluster_order_aggregate {
        label="Order Aggregate";
        style=filled;
        color=lightblue;

        Order [shape=box, style="rounded,filled", fillcolor=gold, label="Order\n(Root)"];
        OrderLine [label="OrderLine"];
        ShippingAddress [label="ShippingAddress"];

        Order -> OrderLine [label="contains"];
        Order -> ShippingAddress [label="has"];
    }

    subgraph cluster_customer_aggregate {
        label="Customer Aggregate";
        style=filled;
        color=lightgreen;

        Customer [shape=box, style="rounded,filled", fillcolor=gold, label="Customer\n(Root)"];
        Address [label="Address"];

        Customer -> Address [label="has many"];
    }

    subgraph cluster_product_aggregate {
        label="Product Aggregate";
        style=filled;
        color=lightyellow;

        Product [shape=box, style="rounded,filled", fillcolor=gold, label="Product\n(Root)"];
        Price [label="Price"];
        Inventory [label="Inventory"];

        Product -> Price [label="has"];
        Product -> Inventory [label="tracks"];
    }

    // Cross-aggregate references (by ID only)
    Order -> Customer [style=dashed, label="customerId"];
    OrderLine -> Product [style=dashed, label="productId"];
}
```

### Layered Architecture

**Use for:** Showing architectural layers and flow

```dot
digraph architecture {
    rankdir=TB;
    node [shape=box, width=3];

    subgraph cluster_presentation {
        label="Presentation Layer";
        style=filled;
        color=lightblue;
        API [label="REST API"];
        WebUI [label="Web UI"];
    }

    subgraph cluster_application {
        label="Application Layer";
        style=filled;
        color=lightgreen;
        Workflows [label="Workflows & Use Cases"];
    }

    subgraph cluster_domain {
        label="Domain Layer";
        style=filled;
        color=gold;
        DomainLogic [label="Domain Logic"];
        DomainTypes [label="Domain Types"];
    }

    subgraph cluster_infrastructure {
        label="Infrastructure Layer";
        style=filled;
        color=lightgrey;
        Database [label="Database"];
        ExternalAPIs [label="External APIs"];
        MessageQueue [label="Message Queue"];
    }

    API -> Workflows;
    WebUI -> Workflows;
    Workflows -> DomainLogic;
    DomainLogic -> DomainTypes;
    Workflows -> Database [style=dashed];
    Workflows -> ExternalAPIs [style=dashed];
    Workflows -> MessageQueue [style=dashed];

    {rank=same; API; WebUI}
    {rank=same; Database; ExternalAPIs; MessageQueue}
}
```

### Data Flow Diagrams

**Use for:** Showing how data moves through the system

```dot
digraph dataflow {
    rankdir=LR;
    node [shape=circle];

    Input [label="External\nInput"];
    Parse [label="Parse"];
    Validate [label="Validate"];
    Transform [label="Transform"];
    Execute [label="Execute\nLogic"];
    Persist [label="Persist"];
    Output [label="External\nOutput"];

    Input -> Parse [label="raw data"];
    Parse -> Validate [label="structured data"];
    Validate -> Transform [label="validated data"];
    Transform -> Execute [label="domain types"];
    Execute -> Persist [label="results"];
    Persist -> Output [label="response"];

    // Error paths
    Parse -> Output [label="parse error", style=dashed, color=red];
    Validate -> Output [label="validation error", style=dashed, color=red];
    Execute -> Output [label="business error", style=dashed, color=red];
    Persist -> Output [label="persistence error", style=dashed, color=red];
}
```

## ASCII Diagrams

### Simple Hierarchies

**Use for:** Quick sketches, documentation, inline comments

```
Domain Model Hierarchy
======================

Order (Aggregate Root)
  ├─> OrderId (Value Object)
  ├─> CustomerId (Value Object)
  ├─> OrderStatus (Enum)
  │    ├─ Draft
  │    ├─ Submitted
  │    ├─ Approved
  │    └─ Fulfilled
  ├─> OrderLines (Collection)
  │    └─> OrderLine
  │         ├─> ProductId
  │         ├─> Quantity
  │         └─> UnitPrice
  └─> PaymentInfo
       ├─> PaymentMethod
       └─> PaymentStatus
```

### Relationships

```
Customer Relationships
=====================

Customer (1) ────places────> (*) Order
                                  │
                                  ├── contains ──> (*) OrderLine
                                  │                     │
                                  │                     └── references ──> (1) Product
                                  │
                                  └── requires ──> (1) Payment
                                                       │
                                                       └── uses ──> (1) PaymentMethod
```

### State Transitions

```
Order Lifecycle
===============

    ┌───────┐
    │ Draft │
    └───┬───┘
        │ submit()
        v
    ┌─────────┐
    │Submitted│
    └────┬────┘
         │
         ├── approve() ────> ┌────────┐
         │                    │Approved│
         │                    └────┬───┘
         │                         │ fulfill()
         │                         v
         │                    ┌─────────┐
         │                    │Fulfilled│────> [END]
         │                    └─────────┘
         │
         └── reject() ─────> ┌────────┐
                              │Rejected│────> [END]
                              └────────┘
```

### Data Flow

```
Order Placement Pipeline
========================

Unvalidated     Validated       Priced         Saved
Order       =>  Order       =>  Order      =>  Order      => Event
   │               │               │               │           │
   └─ validate() ──┘               │               │           │
                   └─ priceOrder() ┘               │           │
                                   └─ saveOrder() ─┘           │
                                                   └─ notify() ┘

Errors:
   ValidationError ─┐
   PricingError ────├──> ErrorHandler ──> ErrorResponse
   DatabaseError ───┘
```

### Component Boxes

```
┌─────────────────────────────────────────────┐
│          Order Management Domain            │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────┐      ┌─────────────────┐ │
│  │   Commands   │      │     Queries     │ │
│  ├──────────────┤      ├─────────────────┤ │
│  │ PlaceOrder   │      │ GetOrder        │ │
│  │ CancelOrder  │      │ ListOrders      │ │
│  │ ApproveOrder │      │ GetOrderHistory │ │
│  └──────────────┘      └─────────────────┘ │
│         │                      │            │
│         v                      v            │
│  ┌──────────────────────────────────────┐  │
│  │        Domain Logic                  │  │
│  │  ┌────────────┐   ┌───────────────┐ │  │
│  │  │ Validation │   │ Business Rules│ │  │
│  │  └────────────┘   └───────────────┘ │  │
│  └──────────────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

### Matrix/Table Layouts

```
State Transition Matrix
=======================

From/To     │ Draft │ Submitted │ Approved │ Rejected │ Fulfilled
────────────┼───────┼───────────┼──────────┼──────────┼──────────
Draft       │   -   │    Yes    │    No    │    No    │    No
Submitted   │  No   │     -     │   Yes    │   Yes    │    No
Approved    │  No   │    No     │    -     │    No    │   Yes
Rejected    │  No   │    No     │    No    │    -     │    No
Fulfilled   │  No   │    No     │    No    │    No    │    -
```

### Layered Architecture

```
Layered Architecture
====================

┌────────────────────────────────────────┐
│      Presentation Layer (API)          │  ← HTTP, JSON, Auth
├────────────────────────────────────────┤
│      Application Layer                 │  ← Workflows, Use Cases
│  ┌──────────────┐  ┌────────────────┐ │
│  │ Order Mgmt   │  │ Customer Mgmt  │ │
│  └──────────────┘  └────────────────┘ │
├────────────────────────────────────────┤
│      Domain Layer                      │  ← Pure Business Logic
│  ┌──────┐  ┌────────┐  ┌───────────┐ │
│  │Types │  │Validation│ │ Business  │ │
│  │      │  │          │  │  Rules    │ │
│  └──────┘  └────────┘  └───────────┘ │
├────────────────────────────────────────┤
│      Infrastructure Layer              │  ← DB, External APIs
│  ┌──────────┐  ┌──────────┐  ┌──────┐│
│  │ Database │  │   HTTP   │  │Email ││
│  └──────────┘  └──────────┘  └──────┘│
└────────────────────────────────────────┘
```

## Choosing the Right Visualization

### Decision Matrix

| Need | Recommended Format | Reason |
|------|-------------------|---------|
| Show entity relationships | Mermaid classDiagram or ER diagram | Clear, standard notation |
| Show business workflow | Mermaid flowchart | Easy to follow decision paths |
| Show state machine | Mermaid stateDiagram | Built-in state diagram support |
| Show message flow | Mermaid sequence diagram | Temporal ordering clear |
| Show module dependencies | Graphviz/DOT | Better layout for complex graphs |
| Show architectural layers | Graphviz/DOT or ASCII | Clear separation of concerns |
| Quick sketch in docs | ASCII | Works everywhere, minimal |
| Inline code comments | ASCII (simple) | Readable in source code |

### Complexity Guidelines

**Simple (1-5 entities/states):**
- ASCII often sufficient
- Quick to create and modify

**Medium (6-15 entities/states):**
- Mermaid recommended
- Good balance of features and simplicity

**Complex (15+ entities/states):**
- Graphviz/DOT for maximum control
- Or break into multiple simpler diagrams

### Communication Context

**For developers:**
- Any format works
- Prefer precision over aesthetics
- Include technical details

**For stakeholders:**
- Mermaid flowcharts (intuitive)
- Avoid technical jargon in labels
- Focus on business concepts

**For documentation:**
- Mermaid (renders in Markdown viewers)
- ASCII for inline code comments
- Include both high-level and detailed views

## Tips and Best Practices

### General Principles

1. **Start simple** - Add complexity only as needed
2. **Use consistent naming** - Match code/domain language exactly
3. **Show relationships clearly** - Label edges meaningfully
4. **Group related concepts** - Use subgraphs/clusters
5. **Highlight important paths** - Use color/style for emphasis
6. **Keep it readable** - Don't cram too much in one diagram

### Mermaid Tips

- Use meaningful IDs (not just A, B, C)
- Add notes for important details
- Use subgraphs for grouping
- Set direction (TD, LR) for best layout

### Graphviz Tips

- Use `rankdir` to control flow direction
- Use `subgraph cluster_*` for grouping
- Use `style=filled` and `color` for visual hierarchy
- Use edge styles (solid, dashed, dotted) to show relationship types

### ASCII Tips

- Use box-drawing characters for cleaner look: ┌─┐│└┘├┤┬┴┼
- Keep lines aligned for readability
- Use indentation to show hierarchy
- Add whitespace for visual separation

### Version Control Friendly

All three formats are text-based and work well with git:
- Easy to diff
- Easy to review in PRs
- Easy to search
- No binary files to worry about

## Templates

### Quick Reference Template

```
Domain: [Domain Name]
====================

Key Entities:
- [Entity1]: [Brief description]
- [Entity2]: [Brief description]

Relationships:
[Entity1] ──> [Entity2]: [relationship description]

States:
[Entity] can be in: [State1] → [State2] → [State3]

Workflows:
1. [Workflow Name]: [Input] → [Step1] → [Step2] → [Output]
```

Use these visualization patterns to clearly communicate domain models and facilitate shared understanding among team members and stakeholders.
