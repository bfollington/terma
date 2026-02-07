# Functional Application Architecture Patterns

## Functional Core, Imperative Shell

The fundamental pattern is to push all I/O and side effects to the edges of the system. Pure functions form the core, while impure operations exist only at the boundaries. This naturally emerges as a Ports and Adapters architecture without extensive design effort.

### Structure
```
┌─────────────────────────┐
│   Imperative Shell      │ ← I/O, Database, HTTP
│  ┌─────────────────┐    │
│  │ Functional Core │    │ ← Pure Business Logic
│  └─────────────────┘    │
└─────────────────────────┘
```

### Key Principle

- **Functional Core**: Contains all business logic as pure functions
- **Imperative Shell**: Handles all I/O and coordinates the pure functions
- **Natural Architecture**: Ports and Adapters emerges without forcing it

## The Impureim Sandwich

Entry points are always impure. The pattern: collect all required data through impure actions, pass to pure function(s), then handle the result with impure actions.

```haskell
-- Pseudo-code pattern
impureHandler input = do
  data1 <- impureRead1        -- Gather inputs
  data2 <- impureRead2
  let result = pureLogic data1 data2  -- Pure computation
  impureWrite result           -- Handle output
```

### Pattern Structure

1. **Top slice**: Impure data gathering
2. **Middle filling**: Pure business logic
3. **Bottom slice**: Impure result handling

This keeps the pure logic completely isolated from effects.

## Module Organization

Separate behavior from data. Data types are simple and transparent. Functions act on these types separately.

### Dependency Ordering
- Bottom: Types with no dependencies
- Middle: Pure functions and domain logic
- Top: I/O and integration layers

### File Structure (Bottom → Top)
```
1. CommonTypes.fs        -- Shared types, no dependencies
2. DomainTypes.fs        -- Domain models
3. DomainLogic.fs        -- Pure business rules
4. Validation.fs         -- Pure validation functions
5. DatabaseTypes.fs      -- DB-specific types
6. DatabaseAccess.fs     -- Impure DB operations
7. HttpHandlers.fs       -- Impure HTTP layer
8. Program.fs            -- Entry point, composition root
```

## Dependency Rejection

Functions should accept data, not capabilities. This is the opposite of dependency injection - we reject dependencies by requiring callers to provide data instead of functions.

### Examples

```fsharp
// ❌ Accepting a function (capability)
let checkCapacity getReservedSeats reservation =
    let reserved = getReservedSeats reservation.Date
    // ...

// ✅ Accepting data
let checkCapacity reservedSeats reservation =
    if capacity < reservation.Quantity + reservedSeats then
        // ...
```

### Benefits

- **Testability**: Pass test data directly, no mocking needed
- **Purity**: Functions remain pure when they only accept data
- **Clarity**: Function signatures show exactly what data is needed
- **Composition**: Pure functions compose more easily

### In Practice

Push the responsibility for I/O up to the caller. The pure function states what data it needs; the impure shell provides it.

## Railway-Oriented Programming

Read and apply the guidance from @./railway.md

Model the flow of success and failure cases explicitly using types like Result/Either. This eliminates ad-hoc error handling and makes the "happy path" clear.

```fsharp
type Result<'Success,'Failure> =
    | Success of 'Success
    | Failure of 'Failure

// Compose with bind (>>=)
let processReservation =
    validateInput
    >> bind checkCapacity
    >> bind saveReservation
    >> map formatResponse
```

## Practical Guidelines

### Pure Functions
- Deterministic: same input → same output
- No side effects or hidden dependencies
- Accept all required data as parameters
- Return explicit results (including errors)

### Impure Boundaries
- Minimize impure code surface area
- Make effects explicit in types where possible
- Compose impure operations at system edges
- Use dependency rejection, not injection

### Testing Strategy
- Pure functions: extensive unit tests
- Impure shell: minimal integration tests
- Focus testing effort on complex pure logic

## Anti-Patterns to Avoid

1. **Scattered I/O**: Mixing pure and impure code throughout
2. **Hidden Effects**: Functions that appear pure but aren't
3. **Capability Passing**: Passing I/O functions into pure code
4. **Anemic Types**: Over-separating data from the functions that operate on it

## Benefits

- **Testability**: Pure functions are trivial to test
- **Reasoning**: Pure code is easier to understand in isolation
- **Composition**: Pure functions compose without surprises
- **Refactoring**: Clear boundaries make changes safer