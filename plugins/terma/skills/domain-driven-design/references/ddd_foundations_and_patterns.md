# DDD Foundations and Practical Patterns

This reference combines Eric Evans' foundational Domain-Driven Design concepts with practical patterns from Clojure and functional programming approaches, plus Martin Fowler's guidance on Ubiquitous Language.

## Eric Evans' Core DDD Concepts

### Ubiquitous Language (Fowler & Evans)

**Definition:** A language structured around the domain model and used by all team members to connect all activities of the team with the software.

**Key Principles:**
- Same language in conversations, documentation, diagrams, and code
- Developed through collaboration between developers and domain experts
- Evolves with the model; changes in language reflect changes in understanding
- No translation between business and technical discussions

**Building Ubiquitous Language:**
1. Listen to how domain experts speak
2. Extract nouns (concepts) and verbs (operations)
3. Challenge vague terms - ask for precision
4. Document terms in a glossary
5. Use these exact terms in code - class names, function names, module names
6. When language feels awkward in code, it reveals model problems

**Red Flags:**
- Developers use different terms than domain experts
- Translation happens between "business language" and "technical language"
- Terms have different meanings in different contexts (without bounded contexts)
- Code uses generic names like "Manager", "Handler", "Processor" instead of domain terms

**Example - Good Ubiquitous Language:**
```clojure
;; Domain expert: "We post a transfer to debit one account and credit another"
(defn post-transfer [transfer-number debit credit]
  ...)

;; NOT:
(defn create-transaction [id source dest]  ; "transaction" is technical jargon
  ...)
```

### Entities

**Definition:** An object defined primarily by its identity, rather than its attributes.

**Characteristics:**
- Has a unique identifier
- Identity persists through time
- Attributes may change while identity remains constant
- Two entities with same attributes but different IDs are distinct

**When to Use:**
- Domain experts refer to things by name/ID
- The thing continues to exist even as its properties change
- Need to track the thing over time or across system boundaries

**Clojure Pattern:**
```clojure
;; Entity: Account (identity = account number)
(s/def :account/number
  (s/and string? #(re-matches #"[1-9]{12}" %)))

(s/def :account/account
  (s/keys :req-un [:account/number   ; The identity
                   :balance/balance])) ; Mutable state

(defn make-account [account-number balance]
  (s/assert :account/account
            {:number account-number
             :balance balance}))

;; Same account, even as balance changes:
(def account-1 (make-account "123456789012" (make-balance 1000 :usd)))
(def account-2 (make-account "123456789012" (make-balance 500 :usd)))
;; account-1 and account-2 represent the same account entity
```

**Immutable Entities:**
Not all entities are mutable. Some are created once and never change:

```clojure
;; Transfer is immutable but still an entity (has identity: transfer number)
(s/def :transfer/number
  (s/and string? #(re-matches #"[A-Z]{3}[1-9]{8}" %)))

(s/def :transfer/transfer
  (s/keys :req-un [:transfer/id
                   :transfer/number  ; Identity
                   :debit/debit
                   :credit/credit
                   :transfer/creation-date]))
```

### Value Objects

**Definition:** An object defined entirely by its attributes, with no identity.

**Characteristics:**
- Defined by what it is, not who it is
- No unique identifier
- Two value objects with same attributes are equivalent
- Typically immutable
- Can be freely shared and replaced

**When to Use:**
- Domain experts describe things by their properties, not by name
- Identity doesn't matter - only the value matters
- Can be replaced with an equivalent value without concern

**Clojure Pattern:**
```clojure
;; Value Object: Amount
(s/def :amount/currency #{:usd :cad})
(s/def :amount/value (s/and number? pos?))

(s/def :amount/amount
  (s/keys :req-un [:amount/currency
                   :amount/value]))

(defn make-amount [value currency]
  (s/assert :amount/amount
            {:currency currency
             :value value}))

;; Two amounts with same value are equivalent:
(= (make-amount 100 :usd) (make-amount 100 :usd)) ; => true
;; No identity - only the value matters
```

**Entity vs Value Object - Decision Guide:**

| Question | Entity | Value Object |
|----------|--------|--------------|
| Do domain experts refer to it by ID/name? | Yes | No |
| Does it change over time? | Often yes | No |
| Do two instances with same attributes mean the same thing? | No | Yes |
| Can you replace it with an equivalent copy? | No | Yes |

### Aggregates and Aggregate Roots

**Definition:** A cluster of domain objects (entities and value objects) that can be treated as a single unit for data changes.

**Aggregate Root:** The single entity through which all operations on the aggregate must pass.

**Purpose:**
- Define transactional consistency boundaries
- Simplify the domain model by grouping related objects
- Enforce invariants that span multiple objects

**Rules:**
1. **External references go only to the aggregate root**
   - Other systems/aggregates can only hold references to the root
   - Never hold a reference to an internal entity

2. **Root enforces all invariants**
   - Only the root can directly change internal entities
   - Internal entities can exist, but external code can't access them directly

3. **Delete removes everything**
   - Deleting the root should delete all internal entities

4. **Transactions don't span aggregates**
   - One transaction = one aggregate
   - Cross-aggregate consistency is eventual

**Example - Order Aggregate:**

Traditional OOP approach would have:
```
Order (root)
  ├─ OrderLine (internal entity)
  ├─ ShippingAddress (value object)
  └─ PaymentInfo (value object)
```

**Clojure/Functional Approach:**
```clojure
;; In Clojure, aggregates are often just nested data with root-level invariants

(s/def ::order-line
  (s/keys :req-un [::product-id ::quantity ::price]))

(s/def ::order
  (s/and
    (s/keys :req-un [::order-id        ; Root identity
                     ::customer-id
                     ::order-lines      ; Collection of internal entities
                     ::shipping-address
                     ::status])
    ;; Aggregate-level invariant:
    (fn [order]
      (and (seq (:order-lines order))   ; Must have at least one line
           (every-price-matches-product (:order-lines order))))))

;; Operations go through the root:
(defn add-order-line [order line]
  ;; Add line and validate aggregate invariants
  (let [updated-order (update order :order-lines conj line)]
    (s/assert ::order updated-order)))

;; External references by ID only:
(s/def ::customer-reference
  (s/keys :req-un [::customer-id]))  ; Reference to Customer aggregate by ID

;; NOT: embedding full customer aggregate
```

**When NOT to Use Aggregates:**

From the Clojure example:
```clojure
;; Transfer involves two accounts, but they don't form an aggregate
;; because accounts can be modified independently of transfers.
;; Instead, transfer-money is a domain service.
```

Not everything that's related should be an aggregate. Ask:
- Do these objects need to change together in a single transaction?
- Do invariants span these objects?
- Can one exist without the other?

**Size Guideline:**
- Keep aggregates small
- Prefer smaller aggregates with eventual consistency between them
- Large aggregates create contention and performance issues

### Domain Services

**Definition:** Operations that don't naturally belong to any single entity or value object.

**When to Use:**
- Operation involves multiple aggregates or entities
- Operation doesn't conceptually belong to one object
- Named after an activity/operation, not a thing

**Clojure Pattern:**
```clojure
;; Domain Service: transfer-money
;; Involves: two Account entities + one Transfer entity
;; Doesn't belong exclusively to any one of them

(defn transfer-money
  "Domain service for transferring money between accounts.
   Pure function that returns domain events describing the changes."
  [transfer-number from-account to-account amount]
  (let [debit (dm/make-debit (:number from-account) amount)
        credit (dm/make-credit (:number to-account) amount)
        debited-account (dm/debit-account from-account debit)
        credited-account (dm/credit-account to-account credit)
        posted-transfer (dm/post-transfer transfer-number debit credit)]
    ;; Return domain event describing all changes
    {:debited-account debited-account
     :credited-account credited-account
     :posted-transfer posted-transfer}))
```

**Domain Service vs Application Service:**

| Domain Service | Application Service |
|----------------|---------------------|
| Pure function | Coordinates effects |
| Domain logic | Orchestration |
| Returns events/new states | Persists changes |
| Part of domain model | Uses domain model |
| No dependencies on infrastructure | Uses repositories, external services |

### Repositories

**Definition:** Provides the illusion of an in-memory collection of aggregates, abstracting persistence.

**Purpose:**
- Encapsulate data access logic
- Provide aggregate-oriented persistence
- Separate domain model from persistence concerns

**Key Characteristics:**
- Operate at aggregate boundaries (save/load whole aggregates)
- Provide lookup by ID
- Hide database/storage implementation
- Return domain entities, not data structures

**Clojure Pattern:**
```clojure
;; Repository provides aggregate-level persistence

(defn get-account
  "Returns Account entity by account-number, nil if not found."
  [account-number]
  (when-let [account-row (fetch-from-db account-number)]
    (account-row->domain-entity account-row)))

(defn save-account
  "Persists Account aggregate."
  [account]
  (let [account-row (domain-entity->account-row account)]
    (persist-to-db account-row)))

;; Application Service orchestrates:
(defn transfer-money-use-case [transfer-number from-id to-id amount]
  ;; Get aggregates
  (let [from-account (repository/get-account from-id)
        to-account (repository/get-account to-id)
        ;; Execute domain logic (pure)
        result (domain-service/transfer-money transfer-number
                                              from-account
                                              to-account
                                              amount)]
    ;; Persist changes
    (repository/commit-transfer-event result)
    result))
```

**Repository vs DAO/Active Record:**
- Repository: Aggregate-oriented, domain-driven
- DAO: Table-oriented, database-driven

### Bounded Contexts

**Definition:** An explicit boundary within which a domain model applies. The same term can mean different things in different contexts.

**Purpose:**
- Manage complexity by dividing the domain
- Allow different models in different parts of the system
- Prevent model corruption from mixing concepts

**Key Insights:**
- Ubiquitous language is only ubiquitous within a context
- Same word can have different meanings in different contexts
- Make boundaries explicit and protect them

**Example:**

```
Bounded Context: Sales
  - "Customer": Entity with sales history, credit limit
  - "Product": Catalog item with pricing

Bounded Context: Shipping
  - "Customer": Just name and shipping address
  - "Product": Weight and dimensions for shipping

Bounded Context: Accounting
  - "Customer": Billing entity with payment terms
  - "Product": Revenue recognition rules
```

**Context Mapping:**

Relationships between bounded contexts:

1. **Shared Kernel**: Two contexts share a subset of the model
2. **Customer/Supplier**: Downstream context depends on upstream
3. **Conformist**: Downstream accepts upstream model as-is
4. **Anti-Corruption Layer**: Translate between contexts to protect model
5. **Separate Ways**: Contexts are completely independent

**Clojure Organization:**
```clojure
;; Each bounded context as a separate namespace or library

;; sales/
;;   domain_model.clj
;;   domain_services.clj
;;   application_service.clj
;;   repository.clj

;; shipping/
;;   domain_model.clj
;;   domain_services.clj
;;   application_service.clj
;;   repository.clj

;; Integration via anti-corruption layer:
(defn sales-customer->shipping-customer [sales-customer]
  {:name (:name sales-customer)
   :shipping-address (:default-address sales-customer)})
```

### Domain Events

**Definition:** Something important that happened in the domain that domain experts care about.

**Characteristics:**
- Named in past tense (OrderPlaced, PaymentProcessed, AccountDebited)
- Immutable facts
- Contain data about what happened
- Can trigger reactions in same or different bounded contexts

**Uses:**
1. **Within a bounded context**: Decouple domain logic
2. **Between bounded contexts**: Integration and eventual consistency
3. **Event Sourcing**: Store events as source of truth

**Clojure Pattern:**
```clojure
;; Domain events describe state changes

(s/def :debited-account/event #{:debited-account})

(s/def :account/debited-account
  (s/keys :req-un [:debited-account/event
                   :account/number
                   :debited-account/amount-value]))

(defn debit-account [account debit]
  ;; Returns domain event describing the change
  (if (valid-debit? account debit)
    {:event :debited-account
     :number (:number account)
     :amount-value (-> debit :amount :value)}
    (throw (ex-info "Can't debit account" {...}))))

;; Application service interprets events:
(defn handle-transfer [result]
  (let [{:keys [debited-account credited-account posted-transfer]} result]
    ;; Persist events
    (persist-event debited-account)
    (persist-event credited-account)
    (persist-event posted-transfer)
    ;; Trigger side effects
    (send-notification (:number debited-account))
    (update-balance-cache debited-account credited-account)))
```

## Functional DDD Architecture

### Layered Architecture (Functional Style)

**Domain Layer (Functional Core):**
- Pure functions
- No IO, no side effects
- Specs for entities, value objects, aggregates
- Domain services as pure transformations
- Returns new values or domain events

**Application Layer (Imperative Shell):**
- Orchestrates use cases
- Fetches data via repositories
- Calls pure domain functions
- Interprets domain events
- Performs side effects

**Infrastructure Layer:**
- Repositories (persistence)
- External services (HTTP, message queues)
- Framework integrations

**Example Structure:**
```clojure
;; Domain Layer (pure)
(ns my-app.domain.model
  (:require [clojure.spec.alpha :as s]))

(s/def ::entity ...)
(defn make-entity [...] ...)
(defn update-entity [entity change] ...)

;; Application Layer (orchestration + effects)
(ns my-app.application
  (:require [my-app.domain.model :as model]
            [my-app.infrastructure.repository :as repo]))

(defn use-case [inputs]
  (let [entity (repo/get-entity (:id inputs))
        updated (model/update-entity entity inputs)]
    (repo/save-entity updated)
    updated))

;; Infrastructure Layer (IO)
(ns my-app.infrastructure.repository)

(defn get-entity [id]
  ;; Database access
  ...)

(defn save-entity [entity]
  ;; Database write
  ...)
```

### Functional Core, Imperative Shell

**Principle:** Maximize pure functional code, minimize and isolate side effects.

**Pattern:**
1. **Shell** reads inputs (IO)
2. **Shell** calls pure **Core** with data
3. **Core** returns results (pure computation)
4. **Shell** performs effects based on results

```clojure
;; CORE: Pure domain logic
(defn calculate-order-total [order]
  (reduce + (map :price (:items order))))

(defn apply-discount [total discount-rules customer]
  ;; Pure calculation
  ...)

;; SHELL: Application service with effects
(defn process-order [order-request]
  ;; Read (effect)
  (let [customer (db/get-customer (:customer-id order-request))
        products (db/get-products (:product-ids order-request))

        ;; Pure domain logic
        order (domain/create-order customer products order-request)
        total (domain/calculate-order-total order)
        final-total (domain/apply-discount total @discount-rules customer)

        ;; Write (effects)
        saved-order (db/save-order (assoc order :total final-total))]

    ;; More effects
    (email/send-confirmation customer saved-order)
    (analytics/track-order saved-order)

    saved-order))
```

## Practical Patterns from Clojure DDD

### Using Specs for Invariants

```clojure
;; Spec defines valid states
(s/def ::transfer
  (s/and
    (s/keys :req-un [::id ::number ::debit ::credit ::creation-date])
    ;; Invariants as predicates:
    (fn [{:keys [debit credit]}]
      (and
        ;; Same amount debited and credited
        (= (:amount debit) (:amount credit))
        ;; Different accounts
        (not= (:number debit) (:number credit))))))

;; Constructor validates on creation
(defn make-transfer [transfer-number debit credit]
  (s/assert ::transfer
            {:id (random-uuid)
             :number transfer-number
             :debit debit
             :credit credit
             :creation-date (java.util.Date.)}))
```

### Event-Driven State Changes

Instead of mutating entities, return events describing changes:

```clojure
;; Instead of: (set! account.balance new-balance)

;; Return event:
(defn debit-account [account debit]
  (if (can-debit? account debit)
    {:event :debited-account
     :account-number (:number account)
     :amount (:value debit)
     :timestamp (now)}
    (throw (ex-info "Cannot debit" {...}))))

;; Repository interprets event:
(defn commit-debit-event [event]
  (swap! state update-in
         [:accounts (:account-number event)]
         apply-debit
         (:amount event)))
```

### Eventual Consistency Trade-offs

From the Clojure example:
```clojure
;; With eventual consistency:
;; - Can process 2000 concurrent transfers
;; - Never double-spend (total money is conserved)
;; - BUT: Account can go temporarily negative

;; Business decision: Is this acceptable?
;; - Maybe: charge overdraft fee
;; - Maybe: customer can cover temporarily
;; - Trade-off: massive scalability for eventual consistency

;; If not acceptable: Use strong consistency (transactions, locks)
;; Trade-off: Lower scalability but immediate consistency
```

## Anti-Patterns to Avoid

### Anemic Domain Model

**Problem:** Entities are just data holders; all logic in services.

```clojure
;; ANEMIC (Bad):
(s/def ::account (s/keys :req-un [::number ::balance]))

(defn debit-account [account amount]
  (update account :balance - amount))  ; No validation!

;; Service does all validation:
(defn debit-with-validation [account amount]
  (if (>= (:balance account) amount)
    (debit-account account amount)
    (throw ...)))
```

**Better:** Put invariants in domain model
```clojure
;; Domain model validates:
(s/def ::account
  (s/and
    (s/keys :req-un [::number ::balance])
    #(>= (:balance %) 0)))  ; Invariant: balance never negative

(defn debit-account [account amount]
  (let [new-account (update account :balance - amount)]
    (s/assert ::account new-account)))  ; Validates invariant
```

### God Aggregates

**Problem:** Massive aggregates that do everything.

**Better:** Keep aggregates small and focused.

### Missing Bounded Contexts

**Problem:** One model trying to serve all use cases.

**Better:** Separate models for separate contexts.

## Checklist for DDD Implementation

- [ ] **Ubiquitous Language**: Same terms in code and conversations
- [ ] **Entities have clear identity**: Can track over time
- [ ] **Value objects are immutable**: Defined by attributes
- [ ] **Aggregates enforce invariants**: Consistency boundaries are clear
- [ ] **Operations through aggregate roots**: No direct access to internals
- [ ] **Domain services for multi-aggregate operations**: Pure functions
- [ ] **Repositories at aggregate level**: Load/save whole aggregates
- [ ] **Application services orchestrate**: Thin layer calling domain
- [ ] **Bounded contexts are explicit**: Clear boundaries and integration
- [ ] **Domain events capture important happenings**: Past tense, immutable

## Key Takeaways

1. **Start with language**: Listen to domain experts, extract ubiquitous language
2. **Entities vs Value Objects**: Identity vs attributes
3. **Aggregates are consistency boundaries**: Keep them small
4. **Domain logic is pure**: No side effects in domain model/services
5. **Repository abstracts persistence**: Aggregate-oriented
6. **Bounded contexts divide complexity**: Different models for different contexts
7. **Domain events decouple**: Integration and eventual consistency
8. **Functional core, imperative shell**: Maximize purity, isolate effects

Always ask:
- What does the domain expert call this?
- Does this have identity or just value?
- What are the invariants?
- What's the consistency boundary?
- Which context are we in?
