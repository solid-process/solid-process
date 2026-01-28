<small>

`Previous` [Basic Usage](./020_BASIC_USAGE.md) | `Next` [Advanced Usage](./040_ADVANCED_USAGE.md)

</small>

# Intermediate Usage

The Steps DSL provides `Given`, `and_then`, `Continue`, and `and_expose` for expressing complex workflows clearly.

## Quick Example

```ruby
class User::Creation < Solid::Process
  input do
    attribute :email, :string
    attribute :name, :string
  end

  def call(attributes)
    rollback_on_failure {
      Given(attributes)
        .and_then(:validate_email)
        .and_then(:create_user)
    }.and_expose(:user_created, [:user])
  end

  private

  def validate_email(email:, **)
    return Failure(:email_taken) if User.exists?(email: email)

    Continue()
  end

  def create_user(email:, name:, **)
    user = User.create!(email: email, name: name)

    Continue(user: user)
  end
end
```

## Key Points

- `Given(attributes)` — starts the step chain with initial data
- `and_then(:method)` — calls a method; short-circuits on Failure
- `Continue(hash)` — merges data and proceeds to next step
- `and_expose(:type, [:keys])` — ends chain with Success containing only specified keys
- `rollback_on_failure { }` — wraps steps in a database transaction
- Always use `**` in step method signatures to ignore extra keys

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Steps DSL](./000_GETTING_STARTED.md#7-steps-dsl) — complete DSL reference
- [Transactions](./000_GETTING_STARTED.md#8-transactions) — rollback strategies
