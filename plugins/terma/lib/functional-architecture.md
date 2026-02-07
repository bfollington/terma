# Functional Application Architecture Patterns

Read and apply the guidance from @./functional-core-imperative-shell.md

Read and apply the guidance from @./impureim-sandwich.md

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

Read and apply the guidance from @./dependency-rejection.md

## Railway-Oriented Programming

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