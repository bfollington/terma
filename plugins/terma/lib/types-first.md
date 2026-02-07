# Types First, Implementation Later

## Core Concept

Start by modeling your domain with types. Implementation details come after you've captured the essential structure. The types aren't just for preventing errors - they're a thinking tool that helps discover the right design.

## Example: State Machine Modeling

```fsharp
// Define the states and their data
type ReadyData = Timed<TimeSpan list>
type ReceivedMessageData = Timed<TimeSpan list * MessageHandler>
type NoMessageData = Timed<TimeSpan list>

// Model the state machine
type PollingConsumer =
    | ReadyState of ReadyData
    | ReceivedMessageState of ReceivedMessageData
    | NoMessageState of NoMessageData
    | StoppedState
```

## Process

1. Identify your domain concepts
2. Model them as types
3. Define relationships between types
4. Only then implement behavior

This approach ensures you understand your problem space before coding solutions.