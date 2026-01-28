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
    * Given(uuid:, name:, email:)
    * Continue() from method: validate_email
    * Continue(user:) from method: create_user
    * Success(:user_created, user:)
 * Continue(user:) from method: create_owner
 * Success(:account_created, user:, account:)
```

## Key Points

- `#0`, `#1`, `#2` show nesting depth for composed processes
- `Given(...)` shows input attributes received
- `Continue(...)` shows intermediate step results with source method
- `Success/Failure(...)` shows final results
- Exceptions are logged with cleaned backtraces

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Instrumentation](./000_GETTING_STARTED.md#13-instrumentation) — complete logging guide
