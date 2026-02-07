# Functional Core, Imperative Shell

## Core Pattern

The fundamental pattern is to push all I/O and side effects to the edges of the system. Pure functions form the core, while impure operations exist only at the boundaries. This naturally emerges as a Ports and Adapters architecture without extensive design effort.

## Structure
```
┌─────────────────────────┐
│   Imperative Shell      │ ← I/O, Database, HTTP
│  ┌─────────────────┐    │
│  │ Functional Core │    │ ← Pure Business Logic
│  └─────────────────┘    │
└─────────────────────────┘
```

## Key Principle

- **Functional Core**: Contains all business logic as pure functions
- **Imperative Shell**: Handles all I/O and coordinates the pure functions
- **Natural Architecture**: Ports and Adapters emerges without forcing it