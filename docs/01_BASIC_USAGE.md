# Basic Usage

**Status:** 🟡 `in-progress`

In this section, we will learn how to create a simple process to register a user.

```ruby
class User::Registration < Solid::Process
  input do
    attribute :email
    attribute :password
    attribute :password_confirmation
  end

  def call(attributes)
    user = User.new(attributes)

    return Failure(:invalid_user, user:) if user.invalid?

    ActiveRecord::Base.transaction do
      user.save!

      account = Account.create!(uuid: SecureRandom.uuid)

      account.memberships.create!(user: user, role: :owner)

      account.task_lists.inbox.create!

      user.create_token!
    end

    UserMailer.with(
      user: user,
      token: user.generate_token_for(:email_confirmation)
    ).email_confirmation.deliver_later

    Success(:user_registered, user: user)
  end
end
```
