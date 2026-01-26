<small>

`Previous` [Intermediate Usage](./030_INTERMEDIATE_USAGE.md) | `Next` [Error Handling](./050_ERROR_HANDLING.md)

</small>

# Advanced Usage

**Status:** 🟡 `in-progress`

In this section, we will learn how to use input normalization and validation, dependencies, and nested processes.

```ruby
class User::Registration < Solid::Process
  deps do
    attribute :mailer, default: UserMailer
    attribute :token_creation, default: User::Token::Creation
    attribute :task_list_creation, default: Account::Task::List::Creation
  end

  input do
    attribute :email, :string
    attribute :password, :string
    attribute :password_confirmation, :string

    before_validation do
      self.email = email.downcase.strip
    end

    with_options presence: true do
      validates :email, format: User::Email::REGEXP
      validates :password, confirmation: true, length: {minimum: User::Password::MINIMUM_LENGTH}
    end
  end

  def call(attributes)
    rollback_on_failure {
      Given(attributes)
        .and_then(:check_if_email_is_taken)
        .and_then(:create_user)
        .and_then(:create_user_account)
        .and_then(:create_user_inbox)
        .and_then(:create_user_token)
    }
      .and_then(:send_email_confirmation)
      .and_expose(:user_registered, [:user])
  end

  private

  def check_if_email_is_taken(email:, **)
    input.errors.add(:email, "has already been taken") if User.exists?(email:)

    input.errors.any? ? Failure(:invalid_input, input:) : Continue()
  end

  def create_user(email:, password:, password_confirmation:, **)
    user = User.create(email:, password:, password_confirmation:)

    return Continue(user:) if user.persisted?

    input.errors.merge!(user.errors)

    Failure(:invalid_input, input:)
  end

  def create_user_account(user:, **)
    account = Account.create!(uuid: SecureRandom.uuid)

    account.memberships.create!(user:, role: :owner)

    Continue(account:)
  end

  def create_user_inbox(account:, **)
    case deps.task_list_creation.call(account:, inbox: true)
    in Solid::Success(task_list:) then Continue()
    end
  end

  def create_user_token(user:, **)
    case deps.token_creation.call(user:)
    in Solid::Success(token:) then Continue()
    end
  end

  def send_email_confirmation(user:, **)
    deps.mailer.with(
      user:,
      token: user.generate_token_for(:email_confirmation)
    ).email_confirmation.deliver_later

    Continue()
  end
end
```

## Input Normalization

### Using `before_validation` (all Rails versions)

The example above uses `before_validation` to normalize the email attribute. This approach works on all supported Rails versions, but normalization only runs when `valid?` is called:

```ruby
input do
  attribute :email, :string

  before_validation do
    self.email = email.downcase.strip
  end
end
```

### Using `normalizes` (Rails 8.1+)

Rails 8.1 introduced `ActiveModel::Attributes::Normalization`, which provides a declarative way to normalize attributes. When available, `Solid::Model` automatically includes it.

Unlike `before_validation`, `normalizes` applies on attribute assignment, so the value is normalized immediately:

```ruby
input do
  attribute :email, :string

  normalizes :email, with: -> { _1.strip.downcase }
end
```

#### Normalize multiple attributes with the same rule

```ruby
input do
  attribute :email, :string
  attribute :username, :string

  normalizes :email, :username, with: -> { _1.strip.downcase }
end
```

#### Different normalizations per attribute

```ruby
input do
  attribute :email, :string
  attribute :phone, :string

  normalizes :email, with: -> { _1.strip.downcase }
  normalizes :phone, with: -> { _1.delete("^0-9").delete_prefix("1") }
end
```

#### Apply normalization to `nil` values

By default, `normalizes` skips `nil` values. Use `apply_to_nil: true` to change this:

```ruby
input do
  attribute :phone, :string

  normalizes :phone, with: -> { _1&.delete("^0-9") || "" }, apply_to_nil: true
end
```

#### Normalize a value without instantiation

Use `normalize_value_for` on the input class to normalize a value directly:

```ruby
UserRegistration.input.normalize_value_for(:email, " FOO@BAR.COM\n")
# => "foo@bar.com"
```
