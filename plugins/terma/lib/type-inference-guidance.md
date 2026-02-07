# Type Inference as Design Guidance

## Let Type Inference Guide You

Don't declare types prematurely. Let inference reveal what your design implies, then evaluate if it makes sense.

```fsharp
// Start with behavior, let types emerge
let transitionFromNoMessage shouldIdle idle nm =
    if shouldIdle nm then
        idle () |> ReadyState
    else
        StoppedState

// Type system infers:
// shouldIdle: NoMessageData -> bool
// idle: unit -> ReadyData
// nm: NoMessageData
```

## Read Inferred Types as Feedback

When a function's inferred type seems wrong, it often reveals a design flaw.

```fsharp
// If idle is inferred as: unit -> Timed<TimeSpan list>
// This suggests it creates statistics from nothing - suspicious!

// Better design preserves existing data:
idle () |> Untimed.withResult nm.Result |> ReadyState
// Now idle: unit -> Timed<'a> - more reasonable
```

## Guidelines

- Start without type annotations
- Let the compiler tell you what types emerge
- Question unusual or complex inferred types
- Add annotations only when design is stable