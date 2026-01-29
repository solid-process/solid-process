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

person = Person.new(name: 'Alice', email: 'alice@example.com')
person.valid?      # => true
person[:email]     # => 'alice@example.com' (hash-style access)
person.slice(:name, :email)  # => {'name'=>'Alice', 'email'=>'alice@example.com'}
```

## Solid::Value

Immutable value objects wrapping a single value:

```ruby
class Email
  include Solid::Value

  before_validation { self.value = value&.strip&.downcase }
  validates presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end

email = Email['  ALICE@EXAMPLE.COM  ']
email.value   # => 'alice@example.com'
email.valid?  # => true

# Value-based equality
Email['a@b.com'] == Email['a@b.com']  # => true (same value = equal)

# Works as hash keys
cache = {}
cache[Email['a@b.com']] = 'data'
cache[Email['a@b.com']]  # => 'data'
```

### Multi-attribute Values

```ruby
class Money
  include Solid::Value
  attribute :amount, :decimal
  attribute :currency, :string
end

Money.new(amount: 100, currency: 'USD') == Money.new(amount: 100, currency: 'USD')
# => true
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

- **Solid::Model** — multiple named attributes, full ActiveModel support, hash-style access
- **Solid::Value** — single `value` attribute, value-based equality, works as hash keys
- **Solid::Input** — Model variant for process inputs, used with `self.input = ClassName`
- All support bracket syntax: `Person[name: 'Alice']`, `Email['a@b.com']`
- All support typed attributes, validations, and callbacks

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Internal Libraries](./000_GETTING_STARTED.md#15-internal-libraries) — complete reference
