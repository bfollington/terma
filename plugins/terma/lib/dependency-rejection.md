# Dependency Rejection

## Key Principle

Functions should accept data, not capabilities. This is the opposite of dependency injection - we reject dependencies by requiring callers to provide data instead of functions.

## Examples

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

## Benefits

- **Testability**: Pass test data directly, no mocking needed
- **Purity**: Functions remain pure when they only accept data
- **Clarity**: Function signatures show exactly what data is needed
- **Composition**: Pure functions compose more easily

## In Practice

Push the responsibility for I/O up to the caller. The pure function states what data it needs; the impure shell provides it.