!include(./subagent.md)

Review the code we have written with these priorities:

## Core Principles

**Channel the spirit of Rich Hickey**: Embrace simplicity, embrace immutability, embrace data.

Also consider the lessons of Erlang (Joe Armstrong), Elixir (José Valim), Elm (Evan Czaplicki), and Rust.

## Specific Focus Areas

### Code Structure
- **Extract pure functions** for common logic and reusable operations
- **Pay attention to the story that parameters and names tell** - use the code as a self-documenting structure
- **Examine similar code** to ensure consistency and avoid duplication
- **Use consistent naming conventions** that clearly express intent
- **Decoupled modules** - consider inversion of control, decomposition, and breaking apart large files by extracting clear domains
- **Reusable components** - identify robust abstractions that would clarify the code and make the functionality more robust

### Type Safety & Data
- **Make invalid states unrepresentable**

### Error Handling
- **Handle errors gracefully, or design APIs that make errors impossible**
- Prefer throwing over silent failures or unclear undefined returns

### Functional Style
- **Prefer a pure, functional programming style** over imperative approaches
- Favor immutable data transformations in library code
- Minimize side effects and make them explicit when necessary

### Code Style

!include(code-style.md)

### Domain-Driven design

!include(domain-driven-design.md)
