<small>

`Previous` [Testing](./060_TESTING.md) | `Next` [Rails Integration](./080_RAILS_INTEGRATION.md)

</small>

# Instrumentation

Enable the BasicLoggerListener to observe process execution, invaluable for debugging complex flows.

## Quick Example

```ruby
# In an initializer (e.g., config/initializers/solid_process.rb)
Solid::Result.config.event_logs.listener = Solid::Process::EventLogs::BasicLoggerListener

# Optionally set a custom logger
Solid::Process::EventLogs::BasicLoggerListener.logger = Logger.new($stdout)
```

## Sample Output

```
#0 Account::OwnerCreation
 * Given(uuid:, owner:)
   #1 User::Creation
    * Given(name:, email:, password:)
    * Continue() from method: validate_email
    * Continue(user:) from method: create_user
      #2 User::Token::Creation
       * Given(user:)
       * Continue(token:) from method: create_token
       * Success(:token_created, token:)
    * Success(:user_created, user:, token:)
 * Success(:account_owner_created, user:, account:)
```

## Exception Output

When an exception occurs, the logger captures it with a cleaned backtrace:

```
Exception:
  Token creation failed (RuntimeError)

Backtrace:
  user_token_creation.rb:28:in `create_token'
```

## Key Points

- `#0`, `#1`, `#2` show nesting depth for composed processes
- `Given(...)` shows input attributes received
- `Continue(...)` shows intermediate step results with source method
- `Success/Failure(...)` shows final results
- Exceptions are logged with cleaned backtraces
- Customize backtrace filtering via `BasicLoggerListener.backtrace_cleaner`

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Instrumentation](../REFERENCE.md#13-instrumentation) — complete logging guide
