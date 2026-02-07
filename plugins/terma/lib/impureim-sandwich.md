# The Impureim Sandwich

Entry points are always impure. The pattern: collect all required data through impure actions, pass to pure function(s), then handle the result with impure actions.

```haskell
-- Pseudo-code pattern
impureHandler input = do
  data1 <- impureRead1        -- Gather inputs
  data2 <- impureRead2
  let result = pureLogic data1 data2  -- Pure computation
  impureWrite result           -- Handle output
```

## Pattern Structure

1. **Top slice**: Impure data gathering
2. **Middle filling**: Pure business logic
3. **Bottom slice**: Impure result handling

This keeps the pure logic completely isolated from effects.