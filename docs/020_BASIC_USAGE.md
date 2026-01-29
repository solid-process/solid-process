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
    # validates :email, :password, presence: true  # See Input Validation section
  end

  def call(attributes)
    user = User.create(attributes)

    if user.persisted?
      Success(:user_registered, user:)
    else
      Failure(:invalid_user, errors: user.errors)
    end
  end
end

# Success case
result = User::Registration.call(email: 'alice@example.com', password: 'secret123')

result.success?       # => true
result.type           # => :user_registered
result[:user]         # => #<User id: 1, email: "alice@example.com">

# Failure case
bad_result = User::Registration.call(email: '', password: '')

bad_result.failure?   # => true
bad_result.type       # => :invalid_user
bad_result[:errors]   # => #<ActiveModel::Errors ...>
```

## Key Points

- `input do ... end` defines what data the process accepts
- `def call(attributes)` receives validated attributes as a hash
- `Success(:type, key: value)` returns a successful result
- `Failure(:type, key: value)` returns a failure result
- Access result data via `result[:key]` (shorthand) or `result.value[:key]`
- Processes are **single-use** — each instance can only be called once

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Your First Process](./000_GETTING_STARTED.md#2-your-first-process) — step-by-step walkthrough
- [Input Definition & Validation](./000_GETTING_STARTED.md#3-input-definition--validation) — types, validations, and more
- [Working with Results](./000_GETTING_STARTED.md#5-working-with-results) — accessing values and checking status
