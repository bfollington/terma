I'll read that article for you and distill its principles.# Write Code That Is Easy to Delete: Tef's Philosophy

## Core Principle: Code as Liability

Every line of code is a line spent, not produced. Code requires maintenance, and the cost grows with dependencies. Instead of building reusable software, build disposable software that's easy to replace when requirements change.

## The Deletion Ladder

### Step 0: Don't Write Code
The easiest code to delete is code you never wrote. Question whether you need to build something before starting.

### Step 1: Copy-Paste Code First
- Duplication is better than the wrong abstraction
- Copy-paste to understand usage patterns
- Shared APIs are harder to change than duplicated code
- Wait for patterns to emerge before abstracting

### Step 2: Extract True Utilities
Pull out only the most generic, stable functionality:
- File operations, logging, collections
- Code unlikely to change with business requirements
- Keep utilities separate from business logic
- Use a `util/` directory, not a single file

### Step 3: Embrace Boilerplate
- Duplicate to avoid dependencies
- Keep protocol separate from policy
- Verbose but flexible is better than clever but rigid
- Write boilerplate in the easy-to-delete parts

### Step 4: Layer Your APIs
Build simple-to-use APIs on top of flexible-but-clumsy ones:
- Separate concerns between layers
- Popular workflows vs. power tools
- Wrap third-party libraries to avoid lock-in
- You can't please everyone at once

### Step 5: Write Big Lumps of Code
Sometimes it's better to write one big mess:
- Business logic is inherently messy
- One big mistake is easier to delete than 18 small ones
- Iterate quickly, fail fast
- Perfect is the enemy of done

### Step 6: Break Apart by Volatility
Decompose by what changes together:
- Hide design decisions that might change
- Isolate hard problems to single modules
- One awful component > two tightly coupled ones
- Handle errors at the edges (end-to-end principle)

### Step 7: Enable Runtime Changes
Build systems that support experimentation:
- Feature flags decouple deployment from release
- Runtime configuration over compile-time
- Feedback loops over upfront design
- Plan to throw one away

## Design Principles

### Manage Dependencies
- Minimize coupling between components
- Duplicate to avoid dependencies
- Layer to manage dependencies
- Isolate to limit dependencies

### Uniform Interfaces
Good examples of deletable code share patterns:
- File systems: fixed operations, many objects
- SQL: standard operations on sets
- HTTP: stateless with standard error codes
- Middleware pipelines and filters

### Separation Strategies
- **By stability**: Separate volatile from stable
- **By responsibility**: Protocol vs. policy
- **By likelihood of change**: Hide decisions that might change
- **By failure modes**: Isolate error handling

### Embrace Change
- Write code assuming you got it wrong
- Build feedback loops, not perfect systems
- Iterate based on real usage
- Delete fearlessly

## Key Insights

1. **Dependencies are the enemy** - They make code hard to change and delete
2. **Duplication has benefits** - It provides flexibility and isolation
3. **Abstraction has costs** - Wait to see patterns before abstracting
4. **Modularity isn't about reuse** - It's about isolating change
5. **Perfect systems don't exist** - Build systems that can evolve
6. **Deletion is success** - Celebrate removed code as progress

## Warning Signs of Hard-to-Delete Code

- Many consumers of an API
- Deep dependency chains
- Business logic in utilities
- Premature abstraction
- Tight coupling between modules
- No clear boundaries

## The Goal

Build software where:
- Components can be replaced independently
- Mistakes are isolated and deletable
- Change is expected and supported
- Dependencies are explicit and minimal
- The hard parts are separated from the easy parts

Good code isn't about getting it right the first time. Good code is legacy code that doesn't get in the way. **Good code is easy to delete.**
