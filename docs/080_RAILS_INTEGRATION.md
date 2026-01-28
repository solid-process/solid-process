<small>

`Previous` [Instrumentation](./070_INSTRUMENTATION.md) | `Next` [Internal Libraries](./090_INTERNAL_LIBRARIES.md)

</small>

# Rails Integration

Solid::Process integrates naturally with Rails controllers, views, and the ActiveModel ecosystem.

## Quick Example

```ruby
# app/processes/user/registration.rb
class User::Registration < Solid::Process
  input do
    attribute :email, :string
    attribute :password, :string
    validates :email, :password, presence: true
  end

  def call(attributes)
    user = User.create(attributes)
    user.persisted? ? Success(:registered, user: user) : Failure(:invalid, user: user)
  end
end

# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  def create
    case User::Registration.call(registration_params)
    in Solid::Success(user:)
      redirect_to dashboard_path, notice: "Welcome!"
    in Solid::Failure[:invalid_input, {input:}]
      render :new, locals: { errors: input.errors }
    in Solid::Failure[:invalid, {user:}]
      render :new, locals: { errors: user.errors }
    end
  end

  private

  def registration_params
    params.require(:registration).permit(:email, :password)
  end
end
```

## Key Points

- Place processes in `app/processes/` (auto-loaded by Rails)
- Use pattern matching in controllers to handle different outcomes
- Input uses ActiveModel — works with Rails form helpers and validations
- `rollback_on_failure` uses `ActiveRecord::Base.transaction` automatically
- Processes work with `deliver_later`, `ActiveJob`, and other Rails components

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Introduction](./000_GETTING_STARTED.md#1-introduction) — installation and setup
- [Pattern Matching](./000_GETTING_STARTED.md#6-pattern-matching) — elegant result handling
