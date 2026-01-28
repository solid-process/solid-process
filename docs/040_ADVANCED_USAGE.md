<small>

`Previous` [Intermediate Usage](./030_INTERMEDIATE_USAGE.md) | `Next` [Error Handling](./050_ERROR_HANDLING.md)

</small>

# Advanced Usage

Use dependencies for testability, input validation for data integrity, and process composition for complex workflows.

## Quick Example

```ruby
class User::Registration < Solid::Process
  deps do
    attribute :mailer, default: UserMailer
    attribute :token_creation, default: User::Token::Creation
  end

  input do
    attribute :email, :string
    attribute :password, :string

    before_validation do
      self.email = email&.strip&.downcase
    end

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: { minimum: 8 }
  end

  def call(attributes)
    user = User.create!(attributes)

    case deps.token_creation.call(user: user)
    in Solid::Success(token:)
      deps.mailer.welcome(user).deliver_later
      Success(:registered, user: user, token: token)
    in Solid::Failure => failure
      Failure(:token_failed, original: failure)
    end
  end
end

# Override dependencies for testing
User::Registration.new(mailer: FakeMailer).call(email: "test@example.com", password: "password123")
```

## Key Points

- `deps do ... end` — defines injectable dependencies with defaults
- `deps.name` — accesses dependencies inside the process
- `before_validation` — normalizes input before validation (all Rails versions)
- `normalizes :attr, with: -> { }` — declarative normalization (Rails 8.1+)
- Dependencies can be swapped at instantiation for testing
- Compose processes by calling one from another via `deps`

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Input Normalization](./000_GETTING_STARTED.md#4-input-normalization) — normalization techniques
- [Dependencies](./000_GETTING_STARTED.md#9-dependencies) — injection patterns
- [Process Composition](./000_GETTING_STARTED.md#10-process-composition) — nesting processes
