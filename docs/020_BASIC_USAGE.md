<small>

`Previous` [Key Concepts](./010_KEY_CONCEPTS.md) | `Next` [Intermediate Usage](./030_INTERMEDIATE_USAGE.md)

</small>

# Basic Usage

Every process needs an `input` block (defining attributes) and a `call` method (returning Success or Failure).

## Quick Example

```ruby
class User::Registration < Solid::Process
  input do
    attribute :email, :string
    attribute :password, :string
  end

  def call(attributes)
    user = User.create(attributes)

    if user.persisted?
      Success(:user_registered, user: user)
    else
      Failure(:invalid_user, errors: user.errors)
    end
  end
end

# Usage
result = User::Registration.call(email: "alice@example.com", password: "secret123")

result.success?       # => true
result.type           # => :user_registered
result.value[:user]   # => #<User id: 1, email: "alice@example.com">
```

## Key Points

- `input do ... end` defines what data the process accepts
- `def call(attributes)` receives validated attributes as a hash
- `Success(:type, key: value)` returns a successful result
- `Failure(:type, key: value)` returns a failure result
- Processes are **single-use** — each instance can only be called once

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Your First Process](./000_GETTING_STARTED.md#2-your-first-process) — step-by-step walkthrough
- [Input Definition & Validation](./000_GETTING_STARTED.md#3-input-definition--validation) — types, validations, and more
- [Working with Results](./000_GETTING_STARTED.md#5-working-with-results) — accessing values and checking status
