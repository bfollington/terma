# Error Design

> A good error message is worth a thousand print statements.

## Core Principles

### 1. Diagnose AND Prescribe

Every error should tell you:
- **What went wrong** (the problem)
- **Where it went wrong** (the context)
- **Why it went wrong** (the cause)
- **How to fix it** (the solution)

```typescript
// Bad: What do I do with this?
throw new Error("Invalid configuration");

// Good: I know exactly what to fix
throw new Error(
  "Invalid database configuration: Missing required field 'host'. " +
  "Add 'host' to your config.json or set DATABASE_HOST environment variable."
);
```

### 2. Context Accumulation

Errors should accumulate context as they bubble up:

```typescript
// Start with specific error
class FileNotFoundError extends Error {
  constructor(public path: string) {
    super(`File not found: ${path}`);
  }
}

// Add context at each layer
try {
  const config = loadConfig("/etc/app/config.json");
} catch (error) {
  throw new ConfigurationError(
    "Failed to load application configuration",
    { cause: error, configPath: "/etc/app/config.json" }
  );
}
```

## When to Use Exceptions vs Results

### Use Exceptions When:
- The error is truly exceptional (programmer error, system failure)
- The error cannot be reasonably handled locally
- You want automatic propagation up the call stack
- Working with APIs that expect exceptions

### Use Result/Either Types When:
- Failure is an expected outcome (user input validation, parsing)
- You want to force explicit error handling
- Working in functional programming paradigms
- Building APIs where errors are part of the contract

```typescript
// Exception: Truly exceptional
function connectToDatabase(config: DbConfig): Connection {
  if (!config.host) {
    throw new Error("Database configuration missing required 'host' field");
  }
  // ...
}

// Result type: Expected failure
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

function parseEmail(input: string): Result<Email, ValidationError> {
  if (!emailRegex.test(input)) {
    return { ok: false, error: new ValidationError("Invalid email format") };
  }
  return { ok: true, value: new Email(input) };
}
```

## Error Hierarchy Design

Design your error hierarchy to enable both specific handling and general fallbacks:

```typescript
// Base error with common functionality
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode?: number,
    public cause?: Error
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

// Category errors
class ValidationError extends AppError {
  constructor(message: string, public fields?: Record<string, string>) {
    super(message, "VALIDATION_ERROR", 400);
  }
}

class AuthenticationError extends AppError {
  constructor(message: string) {
    super(message, "AUTH_ERROR", 401);
  }
}

// Specific errors
class ExpiredTokenError extends AuthenticationError {
  constructor() {
    super("Authentication token has expired. Please log in again.");
  }
}
```

## User vs Developer Errors

### User-Facing Errors
- Clear, actionable language
- No technical jargon
- Suggest next steps
- Apologetic tone for system errors

```typescript
class UserFacingError extends Error {
  constructor(
    public userMessage: string,
    public technicalMessage: string,
    public helpUrl?: string
  ) {
    super(technicalMessage);
  }
}

// Usage
throw new UserFacingError(
  "We couldn't save your changes. Please try again.",
  "Database write failed: connection timeout after 30s",
  "https://help.example.com/save-errors"
);
```

### Developer-Facing Errors
- Technical details
- Stack traces
- Debug information
- Internal error codes

## Structured Error Formats

Use consistent, parseable error formats:

```typescript
interface StructuredError {
  // Unique error identifier
  id: string;
  
  // Machine-readable error code
  code: string;
  
  // Human-readable message
  message: string;
  
  // Additional context
  context?: Record<string, unknown>;
  
  // Chain of causation
  cause?: StructuredError;
  
  // When it happened
  timestamp: string;
  
  // Where it happened
  source?: {
    file?: string;
    line?: number;
    function?: string;
  };
  
  // For user-facing errors
  userMessage?: string;
  helpUrl?: string;
}
```

## Recovery Strategies

### 1. Graceful Degradation
```typescript
async function getUserPreferences(userId: string): Promise<Preferences> {
  try {
    return await fetchFromCache(userId);
  } catch (cacheError) {
    logger.warn("Cache miss, falling back to database", { userId, cacheError });
    try {
      return await fetchFromDatabase(userId);
    } catch (dbError) {
      logger.warn("Database error, using defaults", { userId, dbError });
      return DEFAULT_PREFERENCES;
    }
  }
}
```

### 2. Retry with Backoff
```typescript
async function resilientFetch<T>(
  fn: () => Promise<T>,
  options: { maxRetries: number; backoffMs: number }
): Promise<T> {
  let lastError: Error;
  
  for (let i = 0; i <= options.maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      if (i < options.maxRetries) {
        await sleep(options.backoffMs * Math.pow(2, i));
      }
    }
  }
  
  throw new Error(
    `Failed after ${options.maxRetries} retries: ${lastError.message}`
  );
}
```

### 3. Circuit Breaker
```typescript
class CircuitBreaker {
  private failures = 0;
  private lastFailTime = 0;
  private state: "closed" | "open" | "half-open" = "closed";
  
  async call<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === "open" && Date.now() - this.lastFailTime < 60000) {
      throw new Error("Circuit breaker is open - service unavailable");
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
}
```

## Common Anti-Patterns

### 1. Swallowing Errors
```typescript
// Bad: Error disappears
try {
  doSomething();
} catch (error) {
  // Silent failure
}

// Good: At least log it
try {
  doSomething();
} catch (error) {
  logger.error("Failed to do something", error);
  // Decide: rethrow, recover, or degrade gracefully
}
```

### 2. Stringly-Typed Errors
```typescript
// Bad: String comparison is fragile
if (error.message === "User not found") { }

// Good: Use error types or codes
if (error instanceof UserNotFoundError) { }
if (error.code === "USER_NOT_FOUND") { }
```

### 3. Generic Error Messages
```typescript
// Bad: Not helpful
throw new Error("Operation failed");

// Good: Specific and actionable
throw new Error(
  "Failed to process payment: Card declined (insufficient funds). " +
  "Please use a different payment method."
);
```

### 4. Exposing Internal Details
```typescript
// Bad: Leaks implementation
throw new Error(`PostgreSQL error: duplicate key value violates unique constraint "users_email_key"`);

// Good: User-appropriate message
throw new ValidationError("An account with this email already exists");
```

### 5. Not Preserving Error Chains
```typescript
// Bad: Original error lost
catch (error) {
  throw new Error("Failed to save user");
}

// Good: Preserve the chain
catch (error) {
  throw new Error("Failed to save user", { cause: error });
}
```

## Best Practices Summary

1. **Make errors actionable**: Every error should suggest a fix
2. **Preserve context**: Use error chains and structured data
3. **Design for handling**: Make it easy to catch specific errors
4. **Fail fast, recover gracefully**: Detect errors early, handle them thoughtfully
5. **Log for debugging, display for users**: Separate technical and user-facing messages
6. **Test error paths**: Error handling code needs tests too
7. **Monitor and measure**: Track error rates and types in production

Remember: Good error handling is not about preventing errors—it's about making them productive. When something goes wrong, your errors should help fix the problem, not hide it.