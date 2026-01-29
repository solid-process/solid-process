<small>

`Previous` [Instrumentation](./070_INSTRUMENTATION.md) | `Next` [Internal Libraries](./090_INTERNAL_LIBRARIES.md)

</small>

---

# Rails Integration

Solid::Process integrates naturally with Rails controllers, views, and the ActiveModel ecosystem.

> **Requirements:** Ruby >= 2.7 and Rails >= 6.0

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
    user.persisted? ? Success(:registered, user:) : Failure(:invalid, user:)
  end
end

# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  def new
    @input = User::Registration.input.new
  end

  def create
    case User::Registration.call(registration_params)
    in Solid::Success(user:)
      redirect_to dashboard_path, notice: 'Welcome!'
    in Solid::Failure[:invalid_input, {input:}]
      @input = input
      render :new
    in Solid::Failure[:invalid, {user:}]
      @input = User::Registration.input.new(registration_params)
      @input.errors.merge!(user.errors)
      render :new
    end
  end

  private

  def registration_params
    params.require(:registration).permit(:email, :password)
  end
end
```

## View Integration

```erb
<!-- app/views/registrations/new.html.erb -->
<%= form_with model: @input, url: registrations_path do |f| %>
  <div>
    <%= f.label :email %>
    <%= f.email_field :email %>
    <% if @input&.errors[:email]&.any? %>
      <span class="error"><%= @input.errors[:email].first %></span>
    <% end %>
  </div>
  <%= f.submit 'Register' %>
<% end %>
```

## Key Points

- Place processes in `app/processes/` (auto-loaded by Rails)
- Use pattern matching in controllers to handle different outcomes
- Input uses ActiveModel — works with Rails form helpers and validations
- `rollback_on_failure` uses `ActiveRecord::Base.transaction` automatically
- Processes work with `deliver_later`, `ActiveJob`, and other Rails components
- Requires Ruby >= 2.7 and Rails >= 6.0

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Introduction](../REFERENCE.md#1-introduction) — installation and setup
- [Pattern Matching](../REFERENCE.md#6-pattern-matching) — elegant result handling

---

<small>

`Previous` [Instrumentation](./070_INSTRUMENTATION.md) | `Next` [Internal Libraries](./090_INTERNAL_LIBRARIES.md)

</small>
