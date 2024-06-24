# Advanced Usage

**Status:** 🟡 `in-progress`

In this section, we will learn how to use input normalization and validation, dependencies, and nested processes.

```ruby
class User::Registration < Solid::Process
  input do
    attribute :email, :string
    attribute :password, :string
    attribute :password_confirmation, :string
  end

  def call(attributes)
    rollback_on_failure {
      Given(attributes)
        .and_then(:create_user)
        .and_then(:create_user_account)
        .and_then(:create_user_inbox)
        .and_then(:create_user_token)
    }
      .and_then(:send_email_confirmation)
      .and_expose(:user_registered, [:user])
  end

  private

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
    account.task_lists.inbox.create!

    Continue()
  end

  def create_user_token(user:, **)
    user.create_token!

    Continue()
  end

  def send_email_confirmation(user:, **)
    UserMailer.with(
      user:,
      token: user.generate_token_for(:email_confirmation)
    ).email_confirmation.deliver_later

    Continue()
  end
end
```
