# Always Be Composing: Tellman's Philosophy

## Core Principle: Composition is Interpretation

Software assigns meaning to data in context. Each function interprets its inputs, yielding results that can be interpreted by other functions. This creates an endless chain of interpretation - there is no final, definitive meaning.

## The Process Model

### Definition
A **process** is the smallest standalone unit of computation with three properties:
- Sequential actions
- Execution isolation (when it runs)
- Data isolation (where it runs)

### Three Phases
Every useful process must:
1. **Pull** - Acquire appropriately sized/shaped data
2. **Transform** - Convert data to different data
3. **Push** - Emit results elsewhere

## Phase Characteristics

### Pull & Push (Operational)
- Handle the messy reality of I/O
- Define failure modes and timeouts
- Should be minimal - test only in production-like environments
- Create execution boundaries

### Transform (Functional)
- Pure data transformation
- Testable in isolation
- Should be maximal - contain most business logic
- Describes effects through data, not actions

## Data Transformation Types

1. **Accrete** - Add information when you need to know more
2. **Reduce** - Remove differences that don't matter (true abstraction)
3. **Reshape** - Reorganize to aid accretion/reduction (not abstraction)

## Code Stratification

### Business Logic
- Conditional execution on public datatypes
- Upper strata, interpreted by data
- Closed to extension - understand by reading single location

### Library Code
- General-purpose, open to interpretation
- Relies heavily on function references
- Conditional execution only on internal types

### Glue Code
- Attempts to preserve meaning in different forms
- Translation, not interpretation
- The inevitable connective tissue

## Design Principles

### Abstraction
To abstract is to treat different things as equivalent. Abstractions must be judged within context - they have no inherent quality in isolation.

### Composition Strategy
- Components belong to single phases
- Keep transform phase large and testable
- Keep operational phases small and defensive
- Maintain strong invariants at process boundaries

### Failure Expectations
- Have low expectations of external systems
- Plan for disappointment
- Use backpressure to enforce shared execution models
- Acknowledge actions, not just communication

## Key Insights

1. **Meaning requires context** - Software and data interpret each other
2. **Ignorance is bliss** - Hide complexity behind clean interfaces
3. **Separation is operational** - It's about runtime behavior, not just code organization
4. **Functions can only accrete** - True reduction happens through data transformation
5. **Process boundaries matter** - Strong invariants enable incremental understanding
