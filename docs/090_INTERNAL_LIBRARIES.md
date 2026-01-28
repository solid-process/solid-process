<small>

`Previous` [Rails Integration](./080_RAILS_INTEGRATION.md) | `Next` [Ports and Adapters](./100_PORTS_AND_ADAPTERS.md)

</small>

# Internal Libraries

Solid::Process includes three internal libraries you can use independently: Model, Value, and Input.

## Solid::Model

ActiveModel-based objects with attributes, validations, and callbacks:

```ruby
class Person
  include Solid::Model

  attribute :name, :string
  attribute :email, :string

  validates :name, :email, presence: true
end

person = Person.new(name: "Alice", email: "alice@example.com")
person.valid?  # => true
```

## Solid::Value

Immutable value objects wrapping a single value:

```ruby
class Email
  include Solid::Value

  before_validation { self.value = value&.strip&.downcase }
  validates presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end

email = Email["  ALICE@EXAMPLE.COM  "]
email.value   # => "alice@example.com"
email.valid?  # => true
```

## Solid::Input

Specialized Model for process inputs (created by `input do ... end`):

```ruby
class UserInput < Solid::Input
  attribute :email, :string
  validates :email, presence: true
end

class User::Creation < Solid::Process
  self.input = UserInput  # Use standalone input class
  # ...
end
```

## Key Points

- **Solid::Model** — multiple named attributes, full ActiveModel support
- **Solid::Value** — single `value` attribute, instantiate with `Value[val]`
- **Solid::Input** — Model variant for process inputs, auto-created by `input` block
- All support typed attributes, validations, and callbacks

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Internal Libraries](./000_GETTING_STARTED.md#15-internal-libraries) — complete reference
