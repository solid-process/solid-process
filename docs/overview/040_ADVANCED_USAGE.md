<small>

`Previous` [Intermediate Usage](./030_INTERMEDIATE_USAGE.md) | `Next` [Error Handling](./050_ERROR_HANDLING.md)

</small>

---

# Advanced Usage

Use dependencies for testability, input validation for data integrity, and process composition for complex workflows.

## Quick Example

```ruby
class User::Registration < Solid::Process
  deps do
    attribute :token_creation, default: User::Token::Creation
    attribute :mailer, default: UserMailer
  end

  input do
    attribute :email, :string
    attribute :password, :string

    before_validation do
      self.email = email&.strip&.downcase
    end

    with_options presence: true do
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
      validates :password, length: { minimum: 8 }
    end
  end

  def call(attributes)
    rollback_on_failure {
      Given(attributes)
        .and_then(:create_user)
        .and_then(:create_token)
        .and_then(:send_welcome_email)
    }.and_expose(:registered, [:user, :token])
  end

  private

  def create_user(email:, password:, **)
    user = User.create!(email:, password:)
    Continue(user:)
  end

  def create_token(user:, **)
    case deps.token_creation.call(user:)
    in Solid::Success(token:)
      Continue(token:)
    in Solid::Failure => failure
      Failure(:token_failed, original: failure)
    end
  end

  def send_welcome_email(user:, **)
    deps.mailer.welcome(user).deliver_later
    Continue()
  end
end

# Override dependencies for testing
User::Registration.new(mailer: FakeMailer, token_creation: FakeTokenCreation)
  .call(email: 'test@example.com', password: 'password123')
```

## Key Points

- `deps do ... end` — defines injectable dependencies with defaults
- `deps.name` — accesses dependencies inside the process
- `rollback_on_failure { ... }` — wraps operations in a database transaction; if any step returns Failure, the transaction is rolled back
- `before_validation` — normalizes input before validation (all Rails versions)
- `normalizes :attr, with: -> { }` — declarative normalization (Rails 8.1+)
- Dependencies can be swapped at instantiation for testing
- Compose processes by calling one from another via `deps`
- Pattern match on nested process results to handle success/failure

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Input Normalization](../REFERENCE.md#4-input-normalization) — normalization techniques
- [Dependencies](../REFERENCE.md#9-dependencies) — injection patterns
- [Process Composition](../REFERENCE.md#10-process-composition) — nesting processes
- [Transactions](../REFERENCE.md#8-transactions) — rollback behavior

---

<small>

`Previous` [Intermediate Usage](./030_INTERMEDIATE_USAGE.md) | `Next` [Error Handling](./050_ERROR_HANDLING.md)

</small>
