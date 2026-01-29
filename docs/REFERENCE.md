<small>

`Previous` [README](../README.md#-table-of-contents-) | `Next` [Quick Overview](overview/010_KEY_CONCEPTS.md)

</small>

---

# Solid::Process — Reference Guide

This guide teaches everything you need to know about Solid::Process, from basic concepts to advanced patterns. Work through it progressively, or jump to the section you need.

## Table of Contents

1. [Introduction](#1-introduction)
2. [Your First Process](#2-your-first-process)
3. [Input Definition & Validation](#3-input-definition--validation)
4. [Input Normalization](#4-input-normalization)
5. [Working with Results](#5-working-with-results)
6. [Pattern Matching](#6-pattern-matching)
7. [Steps DSL](#7-steps-dsl)
8. [Transactions](#8-transactions)
9. [Dependencies](#9-dependencies)
10. [Process Composition](#10-process-composition)
11. [Callbacks](#11-callbacks)
12. [Error Handling](#12-error-handling)
13. [Instrumentation](#13-instrumentation)
14. [Validators Reference](#14-validators-reference)
15. [Internal Libraries](#15-internal-libraries)
16. [Testing](#16-testing)

---

## 1. Introduction

### What is Solid::Process?

`Solid::Process` is a Ruby/Rails library for encapsulating business logic into manageable, testable processes. Think of it as an **orchestrator** that knows the order, what to use, and the steps necessary to produce an expected result.

Instead of scattering business logic across controllers, models, and service objects, you write self-contained processes that:

- Define their inputs with types and validations
- Return explicit Success or Failure results
- Can be composed together
- Are easy to test in isolation

### Why not just use...?

Unlike plain service objects, `Solid::Process` provides built-in input validation, result typing, and observability. Unlike Interactors, it offers a Steps DSL for explicit flow control. Unlike Dry::Transaction, it integrates seamlessly with Rails conventions.

### The Philosophy: Emergent Design

Business rules are directly coupled with business needs, and clarity tends to improve over time. Solid::Process embraces this reality through **emergent design** — start simple and add sophistication as you learn what you actually need.

**The Mantra:**

1. **Make it Work** — Write the minimum necessary to implement the process
2. **Make it Better** — Add validations, normalization, and structure as patterns emerge
3. **Make it Even Better** — Use dependencies, composition, and callbacks when complexity demands it

Don't over-engineer upfront. Add features based on actual needs.

### Installation

Add to your Gemfile:

```ruby
gem "solid-process"
```

Or install directly:

```bash
bundle add solid-process
```

Then require it in your code:

```ruby
require "solid/process"
```

### Supported Ruby and Rails Versions

Solid::Process supports Ruby 2.7+ and Rails 6.0+. See the [README](../README.md) for the full compatibility matrix.

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 2. Your First Process

Every `Solid::Process` requires two things:

1. An **input** block that defines the attributes needed to perform the work
2. A **call** method that does the work and returns a `Success` or `Failure`

### Basic Structure

```ruby
class Greeting < Solid::Process
  input do
    attribute :name
  end

  def call(attributes)
    name = attributes[:name]

    if name.present?
      Success(:greeting_created, message: "Hello, #{name}!")
    else
      Failure(:invalid_name, error: "Name cannot be blank")
    end
  end
end
```

Let's break this down:

- `input do ... end` defines what data the process accepts
- `attribute :name` declares a required input attribute
- `def call(attributes)` receives a hash of the validated attributes
- `Success(:type, key: value)` returns a successful result with a type and data
- `Failure(:type, key: value)` returns a failure result with a type and data

### Calling a Process

You can call a process in two ways:

```ruby
# Class method call (most common)
result = Greeting.call(name: "Alice")

# Instance method call
process = Greeting.new
result = process.call(name: "Alice")
```

### Working with Results

The result object tells you whether the process succeeded or failed:

```ruby
result = Greeting.call(name: "Alice")

result.success?                    # => true
result.failure?                    # => false
result.type                        # => :greeting_created
result.value                       # => {message: "Hello, Alice!"}
result.value[:message]             # => "Hello, Alice!"
```

### Single-Use Instances

Process instances are **stateful** and can only be called once:

```ruby
process = Greeting.new
process.call(name: "Alice")  # Works

process.call(name: "Bob")    # Raises Solid::Process::Error!
# "The `Greeting#output` is already set. Use `.output` to access the result
#  or create a new instance to call again."
```

This design ensures that each process execution is isolated and predictable. If you need to call a process multiple times, create new instances:

```ruby
# Create a fresh instance each time
result1 = Greeting.new.call(name: "Alice")
result2 = Greeting.new.call(name: "Bob")

# Or use the class method (creates a new instance internally)
result1 = Greeting.call(name: "Alice")
result2 = Greeting.call(name: "Bob")
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 3. Input Definition & Validation

Solid::Process uses ActiveModel under the hood, giving you the full power of Rails validations for your process inputs.

### Defining Attributes

The `input` block accepts `attribute` declarations with optional types and defaults:

```ruby
class User::Registration < Solid::Process
  input do
    attribute :name, :string
    attribute :email, :string
    attribute :role, :string, default: "member"
    attribute :created_at, :time, default: -> { Time.current }
  end

  def call(attributes)
    # attributes[:role] will be "member" if not provided
    # attributes[:created_at] will be the current time if not provided
    Success(:registered, user: attributes)
  end
end
```

Supported types include `:string`, `:integer`, `:float`, `:boolean`, `:date`, `:time`, `:datetime`, and more (all ActiveModel types).

### Adding Validations

Use standard ActiveModel validations:

```ruby
class User::Registration < Solid::Process
  input do
    attribute :name, :string
    attribute :email, :string
    attribute :password, :string
    attribute :password_confirmation, :string

    validates :name, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: { minimum: 8 }
    validates :password_confirmation, presence: true
  end

  def call(attributes)
    # This code only runs if all validations pass!
    user = User.create!(attributes)
    Success(:user_registered, user: user)
  end
end
```

### Automatic Short-Circuit on Invalid Input

When input validation fails, the process returns `Failure(:invalid_input)` **without executing your call method**:

```ruby
result = User::Registration.call(name: "", email: "bad", password: "short")

result.failure?                    # => true
result.type                        # => :invalid_input
result.value[:input].errors.full_messages
# => ["Name can't be blank", "Email is invalid", "Password is too short (minimum is 8 characters)"]
```

This is a key feature — you don't need to manually check `input.valid?` in most cases.

### Accessing the Input Object

Inside your `call` method, you can access the input object directly:

```ruby
def call(attributes)
  # The attributes hash contains the validated values
  puts attributes[:email]

  # The input object gives you access to validations and the original object
  puts input.email
  puts input.valid?
  puts input.errors.full_messages

  Success(:done)
end
```

### Grouping Validations

Use `with_options` to apply the same options to multiple validations:

```ruby
input do
  attribute :name, :string
  attribute :email, :string
  attribute :password, :string

  with_options presence: true do
    validates :name
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, length: { minimum: 8 }
  end
end
```

### Using External Input Classes

For reusable input definitions, you can define a separate class:

```ruby
class UserInput < Solid::Input
  attribute :name, :string
  attribute :email, :string

  validates :name, :email, presence: true
end

class User::Registration < Solid::Process
  self.input = UserInput

  def call(attributes)
    # ...
  end
end
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 4. Input Normalization

Often you need to transform input values before validation — trimming whitespace, downcasing emails, etc.

### Using `before_validation` (All Rails Versions)

The `before_validation` callback runs before validations and is available in all supported Rails versions:

```ruby
class User::Registration < Solid::Process
  input do
    attribute :name, :string
    attribute :email, :string

    before_validation do |input|
      input.name = input.name&.strip&.gsub(/\s+/, " ")
      input.email = input.email&.strip&.downcase
    end

    validates :name, :email, presence: true
  end

  def call(attributes)
    # attributes[:email] is already stripped and downcased
    Success(:registered, email: attributes[:email])
  end
end

result = User::Registration.call(name: "  John  Doe  ", email: "  JOHN@EXAMPLE.COM  ")
result.value[:email]  # => "john@example.com"
```

**Important:** Normalization via `before_validation` only runs when `valid?` is called. This happens automatically when you call the process.

### Using `normalizes` (Rails 8.1+)

Rails 8.1 introduced `ActiveModel::Attributes::Normalization`, which provides a declarative way to normalize attributes. When available, `Solid::Model` (and thus process inputs) automatically includes it.

Unlike `before_validation`, `normalizes` applies **on attribute assignment**, so values are normalized immediately:

```ruby
class User::Registration < Solid::Process
  input do
    attribute :email, :string

    normalizes :email, with: -> { _1&.strip&.downcase }

    validates :email, presence: true
  end

  def call(attributes)
    Success(:registered, email: attributes[:email])
  end
end
```

**Normalize multiple attributes with the same rule:**

```ruby
input do
  attribute :email, :string
  attribute :username, :string

  normalizes :email, :username, with: -> { _1&.strip&.downcase }
end
```

**Different normalizations per attribute:**

```ruby
input do
  attribute :email, :string
  attribute :phone, :string

  normalizes :email, with: -> { _1&.strip&.downcase }
  normalizes :phone, with: -> { _1&.delete("^0-9")&.delete_prefix("1") }
end
```

**Apply normalization to nil values:**

By default, `normalizes` skips nil values. Use `apply_to_nil: true` to change this:

```ruby
input do
  attribute :phone, :string

  normalizes :phone, with: -> { _1&.delete("^0-9") || "" }, apply_to_nil: true
end
```

**Normalize a value without instantiation:**

```ruby
UserRegistration.input.normalize_value_for(:email, " FOO@BAR.COM\n")
# => "foo@bar.com"
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 5. Working with Results

Every process returns a `Solid::Result` object representing either `Success` or `Failure`.

### Creating Results

Inside your `call` method, use `Success` and `Failure` to return results:

```ruby
def call(attributes)
  user = User.create(attributes)

  if user.persisted?
    Success(:user_created, user: user)
  else
    Failure(:user_not_created, errors: user.errors)
  end
end
```

The first argument is the **type** (a symbol describing what happened), and the remaining keyword arguments form the **value** hash.

### Checking Result Status

```ruby
result = MyProcess.call(input)

# Basic checks
result.success?                    # => true/false
result.failure?                    # => true/false

# Check specific type
result.success?(:user_created)     # => true if success AND type matches
result.failure?(:invalid_input)    # => true if failure AND type matches
```

### Type Checking Methods

Multiple methods for checking result types:

```ruby
result = MyProcess.call(input)

result.type                        # => :user_created (the type symbol)
result.is?(:user_created)          # => true/false
result.type?(:user_created)        # => true/false (alias for is?)
```

### Accessing Values

```ruby
result = User::Registration.call(name: "Alice", email: "alice@example.com")

result.value                       # => {user: #<User id: 1, name: "Alice"...>}
result.value[:user]                # => #<User id: 1, ...>

# Shorthand access
result[:user]                      # => #<User id: 1, ...>
```

### Dynamic Predicate Methods

Results support dynamic predicate methods based on the result type:

```ruby
result = User::Registration.call(name: "Alice", email: "alice@example.com")

result.user_created?               # => true (type is :user_created)
result.invalid_input?              # => false
result.something_else?             # => false (unknown types return false)
```

This makes conditional logic very readable:

```ruby
result = User::Registration.call(params)

if result.user_created?
  redirect_to result[:user]
elsif result.invalid_input?
  render :new, locals: { errors: result[:input].errors }
elsif result.email_already_taken?
  flash[:error] = "That email is already registered"
  render :new
end
```

### Result Types Summary

| Class | Description |
|-------|-------------|
| `Solid::Result` | Base class for all results |
| `Solid::Success` | Successful results |
| `Solid::Failure` | Failure results |
| `Solid::Output` | Alias for `Solid::Result` |

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 6. Pattern Matching

Ruby 3.1+ pattern matching provides an elegant way to handle results.

### Basic Pattern Matching

```ruby
result = MyProcess.call(input)

case result
in Solid::Success
  puts "It worked!"
in Solid::Failure
  puts "It failed!"
end
```

### Matching Type and Destructuring Value

**Array-style pattern `[:type, {value}]`:**

```ruby
result = User::Registration.call(params)

case result
in Solid::Success[:user_created, {user:}]
  redirect_to user_path(user)
in Solid::Failure[:invalid_input, {input:}]
  render :new, locals: { errors: input.errors }
in Solid::Failure[:email_already_taken]
  flash[:error] = "Email already taken"
  render :new
end
```

**Hash-style pattern `(type:, value:)`:**

```ruby
case result
in Solid::Success(type: :user_created, value: {user:})
  puts "Created #{user.name}"
in Solid::Success(type:)
  puts "Unknown success type: #{type}"
end
```

**Value-only pattern `(value:)`:**

```ruby
case result
in Solid::Success(value: {user:})
  puts "Got user: #{user.name}"
in Solid::Failure(value: {errors:})
  puts "Errors: #{errors}"
end
```

**Shorthand value pattern `(key: value)`:**

Match value keys directly without the `value:` wrapper:

```ruby
case result
in Solid::Success(user:)
  puts "User: #{user.name}"
in Solid::Failure(input:)
  puts "Input errors: #{input.errors}"
end
```

### Alternative Pattern Classes

All of these work interchangeably for pattern matching:

```ruby
# All equivalent:
in Solid::Success(user:)     # Most specific
in Solid::Result[:user_created, {user:}]  # Matches any result
in Solid::Output(type: :user_created)     # Alias for Result
```

### Complete Example

```ruby
class CreateUser < Solid::Process
  input do
    attribute :email, :string
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  end

  def call(attributes)
    user = User.create!(attributes)
    Success(:user_created, user: user)
  rescue ActiveRecord::RecordInvalid => e
    Failure(:creation_failed, errors: e.record.errors)
  end
end

result = CreateUser.call(email: "alice@example.com")

case result
in Solid::Success[:user_created, {user:}]
  redirect_to user_path(user), notice: "Welcome!"
in Solid::Failure[:invalid_input, {input:}]
  render :new, locals: { errors: input.errors }
in Solid::Failure[:creation_failed, {errors:}]
  render :new, locals: { errors: errors }
end
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 7. Steps DSL

As processes grow more complex, the Steps DSL helps express the workflow clearly.

### The Building Blocks

The Steps DSL provides four key methods:

| Method | Purpose |
|--------|---------|
| `Given(attributes)` | Starts a step chain with initial data |
| `and_then(:method)` | Calls a method that can continue or short-circuit |
| `Continue(hash)` | Passes data to the next step |
| `and_expose(:type, [:keys])` | Ends the chain with a Success containing specified keys |

### Basic Steps Example

```ruby
class User::Token::Creation < Solid::Process
  input do
    attribute :user
    validates :user, presence: true
  end

  def call(attributes)
    Given(attributes)
      .and_then(:validate_token_existence)
      .and_then(:create_token)
      .and_expose(:token_created, [:token])
  end

  private

  def validate_token_existence(user:, **)
    # Return Success early if token already exists (idempotency)
    return Success(:token_already_exists, token: user.token) if user.token&.persisted?

    Continue()  # No data to add, just continue
  end

  def create_token(user:, **)
    token = user.create_token(
      access_token: SecureRandom.hex(24),
      refresh_token: SecureRandom.hex(24)
    )

    if token.persisted?
      Continue(token: token)  # Add token to the data flowing through
    else
      Failure(:token_creation_failed, errors: token.errors)
    end
  end
end
```

### How the Steps DSL Works

1. `Given(attributes)` — Creates a result containing the initial attributes
2. `and_then(:method)` — Calls the method if the previous result was successful; skips if it was a failure
3. Each step receives the accumulated data as keyword arguments
4. `Continue(hash)` — Merges new data into the accumulated data and continues
5. `and_expose(:type, [:keys])` — Creates a final `Success` with only the specified keys

**Key insight:** If any step returns a `Failure` or `Success` (not `Continue`), the chain short-circuits and that becomes the final result.

### The `**` Splat Operator

Notice the `**` in method signatures like `def validate_token_existence(user:, **)`. This is essential because:

1. It extracts only the keys you care about (`user:`)
2. It ignores additional keys in the accumulated data (`**`)

Without `**`, Ruby would raise an error when the data hash contains keys you didn't declare.

### Early Success (Idempotency Pattern)

The `validate_token_existence` step demonstrates an important pattern. Instead of raising an error when a token already exists, it returns a `Success` early:

```ruby
def validate_token_existence(user:, **)
  return Success(:token_already_exists, token: user.token) if user.token&.persisted?
  Continue()
end
```

This makes the process **idempotent** — calling it multiple times with the same user produces the same result without creating duplicate tokens.

### `Continue` vs `Success`/`Failure`

| Method | Effect |
|--------|--------|
| `Continue()` | Merge data and move to next step |
| `Continue(key: val)` | Merge `{key: val}` and move to next step |
| `Success(:type, ...)` | Stop the chain, return this Success as final result |
| `Failure(:type, ...)` | Stop the chain, return this Failure as final result |

Use `Continue` when you want to keep going. Use `Success`/`Failure` when you want to stop immediately.

### `and_expose` — Finishing the Chain

The `and_expose` method creates a final `Success` result with only the keys you specify:

```ruby
Given(a: 1, b: 2, c: 3)
  .and_then(:add_d)    # adds d: 4
  .and_expose(:done, [:a, :d])

# Result: Success(:done, a: 1, d: 4)
# b and c are NOT included
```

This keeps your results clean, exposing only what callers need.

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 8. Transactions

When your process makes database changes, you often want to roll back all changes if something fails.

### The `rollback_on_failure` Block

Wrap steps in `rollback_on_failure` to automatically roll back database changes if any step fails:

```ruby
class User::Registration < Solid::Process
  input do
    attribute :email, :string
    attribute :password, :string

    validates :email, :password, presence: true
  end

  def call(attributes)
    rollback_on_failure {
      Given(attributes)
        .and_then(:create_user)
        .and_then(:create_profile)
        .and_then(:send_welcome_email)
    }.and_expose(:registered, [:user])
  end

  private

  def create_user(email:, password:, **)
    user = User.create(email: email, password: password)
    user.persisted? ? Continue(user: user) : Failure(:user_creation_failed, errors: user.errors)
  end

  def create_profile(user:, **)
    profile = user.create_profile!
    Continue(profile: profile)
  end

  def send_welcome_email(user:, **)
    # If this fails, both user and profile are rolled back
    UserMailer.welcome(user).deliver_later
    Continue()
  end
end
```

If `send_welcome_email` fails, the user and profile created in previous steps are rolled back.

### Scoped Transactions

Sometimes you want only *some* steps inside the transaction. A common pattern is to validate outside the transaction and write inside:

```ruby
class User::Creation < Solid::Process
  input do
    attribute :email, :string
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  end

  def call(attributes)
    Given(attributes)
      .and_then(:validate_email_uniqueness)  # Outside transaction
      .then { |result|
        rollback_on_failure {
          result
            .and_then(:create_user)           # Inside transaction
            .and_then(:create_user_token)     # Inside transaction
        }
      }
      .and_expose(:user_created, [:user, :token])
  end

  private

  def validate_email_uniqueness(email:, **)
    User.exists?(email: email) ? Failure(:email_already_taken) : Continue()
  end

  def create_user(email:, **)
    user = User.create!(email: email)
    Continue(user: user)
  end

  def create_user_token(user:, **)
    token = user.create_token!
    Continue(token: token)
  end
end
```

The `.then { |result| ... }` pattern lets you wrap only part of the chain in a transaction.

### How `rollback_on_failure` Works

1. It opens an ActiveRecord transaction
2. It executes the block
3. If the result is a `Failure`, it raises `ActiveRecord::Rollback`
4. The transaction is rolled back
5. The `Failure` result is returned

**Note:** `rollback_on_failure` requires ActiveRecord and an active database connection.

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 9. Dependencies

Dependency injection makes processes easier to test and more flexible. The `deps` block defines external collaborators that can be swapped.

### Defining Dependencies

```ruby
class User::Creation < Solid::Process
  deps do
    attribute :repository, default: User
    attribute :mailer, default: UserMailer
  end

  input do
    attribute :email, :string
    validates :email, presence: true
  end

  def call(attributes)
    user = deps.repository.create!(attributes)
    deps.mailer.welcome(user).deliver_later

    Success(:user_created, user: user)
  end
end
```

### Accessing Dependencies

Inside your process, access dependencies via `deps` (or `dependencies`):

```ruby
def call(attributes)
  user = deps.repository.create!(attributes)  # Using deps shorthand
  dependencies.mailer.welcome(user)           # Full name also works

  Success(:user_created, user: user)
end
```

### Injecting Dependencies at Runtime

Override defaults when instantiating the process:

```ruby
# With default dependencies
User::Creation.call(email: "alice@example.com")

# With injected dependencies
fake_repo = FakeUserRepository.new
fake_mailer = FakeMailer.new

User::Creation
  .new(repository: fake_repo, mailer: fake_mailer)
  .call(email: "alice@example.com")
```

### Validating Dependencies

Dependencies support the same validations as inputs:

```ruby
deps do
  attribute :repository, default: User

  validate :repository_interface

  def repository_interface
    unless repository.respond_to?(:create!)
      errors.add(:repository, "must respond to create!")
    end
  end
end
```

If dependency validation fails, the process returns `Failure(:invalid_dependencies)` without executing your call method.

### Dependencies for Process Composition

A common pattern is injecting other processes as dependencies:

```ruby
class Account::OwnerCreation < Solid::Process
  deps do
    attribute :user_creation, default: User::Creation
  end

  input do
    attribute :owner_params
  end

  def call(attributes)
    case deps.user_creation.call(attributes[:owner_params])
    in Solid::Success(user:)
      account = Account.create!(owner: user)
      Success(:account_created, account: account, user: user)
    in Solid::Failure => failure
      failure  # Propagate the failure
    end
  end
end
```

This allows you to swap `User::Creation` with a mock in tests.

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 10. Process Composition

Real applications compose multiple processes together. This section shows patterns for doing this effectively.

### Calling Processes from Processes

The simplest approach uses pattern matching on the nested process result:

```ruby
class Account::OwnerCreation < Solid::Process
  deps do
    attribute :user_creation, default: User::Creation
  end

  input do
    attribute :uuid, :string, default: -> { SecureRandom.uuid }
    attribute :owner
  end

  def call(attributes)
    rollback_on_failure {
      Given(attributes)
        .and_then(:create_owner)
        .and_then(:create_account)
        .and_then(:link_owner_to_account)
    }.and_expose(:account_owner_created, [:user, :account])
  end

  private

  def create_owner(owner:, **)
    case deps.user_creation.call(owner)
    in Solid::Success(user:, token:)
      Continue(user: user, user_token: token)
    in Solid::Failure(type:, value:)
      Failure(:invalid_owner, **{type => value})
    end
  end

  def create_account(uuid:, **)
    account = Account.create!(uuid: uuid)
    Continue(account: account)
  end

  def link_owner_to_account(account:, user:, **)
    Member.create!(account: account, user: user, role: :owner)
    Continue()
  end
end
```

### Error Wrapping Pattern

Notice how `create_owner` wraps the nested failure:

```ruby
in Solid::Failure(type:, value:)
  Failure(:invalid_owner, **{type => value})
end
```

This creates a failure like `Failure(:invalid_owner, email_already_taken: {...})`. The outer process indicates *what* failed (`:invalid_owner`), while preserving *why* it failed from the inner process.

Callers can handle this hierarchically:

```ruby
case result
in Solid::Failure[:invalid_owner, {email_already_taken:}]
  flash[:error] = "That email is already registered"
in Solid::Failure[:invalid_owner, {invalid_input: {input:}}]
  flash[:error] = input.errors.full_messages.join(", ")
in Solid::Failure[:invalid_owner]
  flash[:error] = "Could not create owner"
end
```

### Handling Nested Results with Steps

Inside a step method, you must explicitly handle the nested result:

```ruby
def create_user_token(user:, **)
  case deps.token_creation.call(user: user)
  in Solid::Success(token:)
    Continue(token: token)
  in Solid::Failure
    raise "Token creation failed unexpectedly"
  end
end
```

You can't just return the nested result directly because `and_then` expects your step to return `Continue`, `Success`, or `Failure` — not another process's result.

### Propagating Failures

If you want to propagate a nested failure unchanged:

```ruby
def create_user_token(user:, **)
  result = deps.token_creation.call(user: user)

  return Failure(result.type, **result.value) if result.failure?

  Continue(token: result[:token])
end
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 11. Callbacks

Callbacks let you hook into the process lifecycle for cross-cutting concerns like logging, metrics, and cleanup.

### Callback Types

| Callback | When it runs |
|----------|--------------|
| `before_call` | Before input validation and call method |
| `around_call` | Wraps the entire execution |
| `after_call` | After every call, regardless of outcome |
| `after_success` | Only when the process returns Success |
| `after_failure` | Only when the process returns Failure |

### Execution Order

```
1. around_call "before" phase
2. before_call
3. Input validation (before_validation, validations, after_validation)
4. call method executes
5. after_success OR after_failure (depending on result)
6. after_call
7. around_call "after" phase
```

### `before_call`

Runs before input validation. Useful for capturing raw input values:

```ruby
class PersonCreation < Solid::Process
  input do
    attribute :email, :string

    before_validation do |input|
      input.email = input.email&.strip&.downcase
    end
  end

  before_call do
    # Runs BEFORE before_validation
    # input.email still has raw, untransformed value
    Rails.logger.info "Creating person with email: #{input.email}"
  end

  def call(attributes)
    # input.email is now transformed
    Success(:created, email: attributes[:email])
  end
end
```

### `after_call`, `after_success`, `after_failure`

```ruby
class PersonCreation < Solid::Process
  input do
    attribute :name, :string
    validates :name, presence: true
  end

  after_success do
    Rails.logger.info "Created person: #{output[:person][:name]}"
    StatsD.increment("person.created")
  end

  after_failure do
    Rails.logger.warn "Failed to create person: #{output.type}"
    StatsD.increment("person.creation_failed")
  end

  after_call do
    # Always runs, after success/failure callbacks
    Rails.logger.debug "Process completed with: #{output.type}"
  end

  def call(attributes)
    Success(:person_created, person: attributes)
  end
end
```

### Conditional Callbacks

Use the `:if` option to run callbacks conditionally:

```ruby
# Using a lambda
after_success if: -> { output.is?(:person_created) } do
  send_welcome_email
end

# Using a method name
after_success if: :person_created? do
  send_welcome_email
end

# The process automatically provides type predicates
after_call if: :success? do
  # Runs only on success
end

after_call if: :failure? do
  # Runs only on failure
end
```

### `around_call`

Wraps the entire execution. Receives the process and a block to yield:

```ruby
class PersonCreation < Solid::Process
  around_call do |process, block|
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    block.call  # Execute the call method

    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    Rails.logger.info "#{self.class.name} took #{elapsed.round(3)}s"
  end

  def call(attributes)
    Success(:created, person: attributes)
  end
end
```

Common use cases for `around_call`:

- Timing/performance measurement
- Database transactions
- Error handling and retry logic
- Setting up request context

### Callback Execution Order (Multiple Callbacks)

Multiple callbacks of the same type execute in **reverse definition order** (last defined runs first):

```ruby
after_success { puts "1" }  # Runs third
after_success { puts "2" }  # Runs second
after_success { puts "3" }  # Runs first
# Output: 3, 2, 1
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 12. Error Handling

### Using `rescue_from`

Like Rails controllers, processes support `rescue_from` for handling exceptions:

```ruby
class Division < Solid::Process
  input do
    attribute :numerator
    attribute :denominator
  end

  rescue_from ZeroDivisionError do |error|
    Failure!(:division_by_zero, error: error)
  end

  def call(attributes)
    result = attributes[:numerator] / attributes[:denominator]
    Success(:calculated, result: result)
  end
end

result = Division.call(numerator: 10, denominator: 0)
result.failure?(:division_by_zero)  # => true
result.value[:error]                # => #<ZeroDivisionError: divided by 0>
```

### Using a Method Handler

Specify a method with the `with:` option:

```ruby
class Division < Solid::Process
  NanError = Class.new(StandardError)

  input do
    attribute :numerator
    attribute :denominator
  end

  rescue_from ZeroDivisionError do |error|
    Failure!(:division_by_zero, error: error)
  end

  rescue_from NanError, with: :handle_nan

  def call(attributes)
    num = attributes[:numerator]
    raise NanError if num.respond_to?(:nan?) && num.nan?

    Success(:calculated, result: num / attributes[:denominator])
  end

  private

  def handle_nan(error)
    Failure!(:invalid_number, error: error)
  end
end
```

### Important: Use `Success!` and `Failure!` in Handlers

Inside `rescue_from` handlers, you must use `Success!` and `Failure!` (with the bang `!`) instead of `Success` and `Failure`. These methods immediately set the output and halt processing.

```ruby
rescue_from SomeError do |error|
  # CORRECT - use bang methods
  Failure!(:error_type, error: error)

  # WRONG - without bang, this won't work properly
  # Failure(:error_type, error: error)
end
```

### Converting Exceptions to Success

You can even convert certain exceptions to successful results:

```ruby
rescue_from RecordAlreadyExistsError do |error|
  # Return the existing record instead of failing
  Success!(:already_exists, record: error.record)
end
```

### Inline Error Handling in Step Methods

For method-level error handling, use standard Ruby `rescue`:

```ruby
def create_user(email:, **)
  user = User.create!(email: email)
  Continue(user: user)
rescue ActiveRecord::RecordInvalid => e
  Failure(:user_creation_failed, errors: e.record.errors)
end
```

This approach is useful when you want different steps to handle the same exception type differently.

### Single Output Rule

The output can only be set once. Attempting to call `Success!` or `Failure!` multiple times raises an error:

```ruby
def handle_error(error)
  # DON'T DO THIS
  2.times { Failure!(:error, error: error) }
end
# => Solid::Process::Error: "`Failure!()` cannot be called because the `MyProcess#output` is already set."
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 13. Instrumentation

Solid::Process provides built-in observability through event logging, invaluable for debugging complex process chains.

### Enabling the BasicLoggerListener

```ruby
# In an initializer or before running processes
Solid::Result.config.event_logs.listener = Solid::Process::EventLogs::BasicLoggerListener

# Optionally configure the logger (defaults to Rails.logger in Rails apps)
Solid::Process::EventLogs::BasicLoggerListener.logger = Logger.new($stdout)
```

### What Gets Logged

The listener captures:

- Process start and finish
- Given inputs (attribute names)
- Continue results (intermediate steps)
- Success/Failure results (final outcomes)
- Nested process calls (hierarchical view)
- Exceptions with cleaned backtraces

### Example Log Output

For the `Account::OwnerCreation` process that nests `User::Creation` which nests `User::Token::Creation`:

```
#0 Account::OwnerCreation
 * Given(uuid:, owner:)
   #1 User::Creation
    * Given(uuid:, name:, email:, password:, password_confirmation:)
    * Continue() from method: validate_email_uniqueness
    * Continue(user:) from method: create_user
      #2 User::Token::Creation
       * Given(user:, executed_at:)
       * Continue() from method: validate_token_existence
       * Continue(token:) from method: create_token_if_not_exists
       * Success(:token_created, token:)
    * Continue(token:) from method: create_user_token
    * Success(:user_created, user:, token:)
 * Continue(user:, user_token:) from method: create_owner
 * Continue(account:) from method: create_account
 * Continue() from method: link_owner_to_account
 * Success(:account_owner_created, user:, account:)
```

Key elements:

- `#0`, `#1`, `#2` — Nesting depth
- `Given(...)` — Input attributes received
- `Continue(...)` — Intermediate step results
- `Success(...)` / `Failure(...)` — Final results
- `from method: name` — Which method produced the result

### Exception Logging

When an exception occurs:

```
#0 Account::OwnerCreation
 * Given(uuid:, owner:)
   #1 User::Creation
    * Continue() from method: validate_email_uniqueness
    * Continue(user:) from method: create_user
      #2 User::Token::Creation
       * Given(user:, executed_at:)
       * Continue() from method: validate_token_existence

Exception:
  Runtime breaker activated (RuntimeBreaker::Interruption)

Backtrace:
  user_token_creation.rb:28:in `create_token_if_not_exists'
  user_token_creation.rb:15:in `call'
  user_creation.rb:61:in `create_user_token'
```

### Customizing the Backtrace Cleaner

```ruby
cleaner = Solid::Process::EventLogs::BasicLoggerListener.backtrace_cleaner

# Add custom silencers to hide certain paths
cleaner.add_silencer { |line| line.include?("/gems/") }
```

### When to Use Instrumentation

- **Development** — Understand process flow and debug issues
- **Production** — Audit process executions and investigate errors
- **Performance** — See which steps execute and identify bottlenecks

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 14. Validators Reference

Solid::Process provides custom validators that extend ActiveModel. All validators support `allow_nil: true` and `allow_blank: true` options.

### email

Validates email address format:

```ruby
validates :email, email: true
```

Valid: `"user@example.com"`, `"name+tag@domain.org"`
Invalid: `"invalid"`, `"@example.com"`, `"user@"`

### uuid

Validates UUID format:

```ruby
validates :id, uuid: true

# Case-insensitive (accepts uppercase)
validates :id, uuid: { case_sensitive: false }
```

Valid: `"550e8400-e29b-41d4-a716-446655440000"`
Invalid: `"not-a-uuid"`, `"12345"`

### id

Validates database-style IDs (positive integers):

```ruby
validates :user_id, id: true
```

Valid: `1`, `42`, `"123"` (string integers)
Invalid: `0`, `-1`, `1.5`, `nil`

### kind_of

Validates class/module inheritance (allows subclasses):

```ruby
validates :amount, kind_of: Numeric
validates :identifier, kind_of: [String, Symbol]
validates :items, kind_of: Enumerable
```

Uses Ruby's `is_a?` / `kind_of?` method.

### instance_of

Validates exact class membership (no subclasses):

```ruby
validates :name, instance_of: String
validates :identifier, instance_of: [String, Symbol]
```

Uses Ruby's `instance_of?` method. Stricter than `kind_of`.

### is

Validates that values satisfy predicate methods:

```ruby
validates :record, is: :persisted?
validates :user, is: [:present?, :persisted?]
```

All predicates must return truthy for validation to pass.

### respond_to

Validates duck-typing by checking method availability:

```ruby
validates :value, respond_to: :to_sym
validates :converter, respond_to: [:to_s, :to_sym]
```

All specified methods must be available.

### singleton

Validates class/module types themselves (not instances):

```ruby
validates :klass, singleton: String
validates :type, singleton: [String, Symbol]
validates :mod, singleton: Enumerable
```

Validates that the value is a class that inherits from, or a module that includes, the specified type.

### Common Options

All validators support these standard ActiveModel options:

```ruby
validates :email, email: true, allow_nil: true    # Skip if nil
validates :email, email: true, allow_blank: true  # Skip if blank (nil or "")
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 15. Internal Libraries

Solid::Process includes several internal libraries that you can use independently.

### Solid::Model

A module for creating ActiveModel-based objects with attributes, validations, and callbacks:

```ruby
class Person
  include Solid::Model

  attribute :name, :string
  attribute :email, :string
  attribute :role, :string, default: "member"

  before_validation do
    self.email = email&.strip&.downcase
  end

  validates :name, :email, presence: true
end

person = Person.new(name: "Alice", email: " ALICE@EXAMPLE.COM ")
person.valid?   # => true
person.email    # => "alice@example.com"
person.role     # => "member"
```

**Features:**

- Typed attributes with defaults
- Full ActiveModel validation support
- Callbacks: `after_initialize`, `before_validation`, `after_validation`
- Hash-style access: `person[:name]`, `person.slice(:name, :email)`
- Bracket instantiation: `Person[name: "Alice"]`

### Solid::Value

A module for creating immutable value objects with a single primary value:

```ruby
class Email
  include Solid::Value

  before_validation do
    self.value = value&.strip&.downcase
  end

  validates presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end

email = Email["  ALICE@EXAMPLE.COM  "]
email.value    # => "alice@example.com"
email.valid?   # => true

invalid = Email["not-an-email"]
invalid.valid? # => false
```

**Key differences from Solid::Model:**

| Feature | Solid::Model | Solid::Value |
|---------|--------------|--------------|
| Attributes | Multiple named attributes | Single `value` attribute |
| Instantiation | `Model.new(attr: val)` | `Value.new(val)` or `Value[val]` |
| Validations | `validates :attr, ...` | `validates presence: true, ...` |
| Purpose | Complex domain objects | Simple wrapped primitives |

### Solid::Input

A specialized form of `Solid::Model` used for process inputs. It's what gets created when you use the `input do ... end` block:

```ruby
class MyProcess < Solid::Process
  input do
    attribute :name, :string
    validates :name, presence: true
  end
end

# The input block creates a Solid::Input subclass
MyProcess.input  # => MyProcess::Input
```

You can also create standalone input classes:

```ruby
class UserInput < Solid::Input
  attribute :name, :string
  attribute :email, :string

  validates :name, :email, presence: true
end

class User::Creation < Solid::Process
  self.input = UserInput
  # ...
end
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## 16. Testing

Solid::Process is designed for testability. Here are patterns for effective testing.

### Testing Process Outcomes

Test the public interface — inputs and outputs:

```ruby
class UserCreationTest < ActiveSupport::TestCase
  test "creates a user with valid input" do
    result = User::Creation.call(
      name: "Alice",
      email: "alice@example.com",
      password: "securepassword",
      password_confirmation: "securepassword"
    )

    assert result.success?
    assert result.is?(:user_created)
    assert_equal "Alice", result[:user].name
    assert_equal "alice@example.com", result[:user].email
  end

  test "fails with invalid email" do
    result = User::Creation.call(
      name: "Alice",
      email: "not-an-email",
      password: "securepassword",
      password_confirmation: "securepassword"
    )

    assert result.failure?
    assert result.is?(:invalid_input)
    assert_includes result[:input].errors[:email], "is invalid"
  end

  test "fails when email is already taken" do
    User.create!(name: "Bob", email: "alice@example.com", password: "password")

    result = User::Creation.call(
      name: "Alice",
      email: "alice@example.com",
      password: "securepassword",
      password_confirmation: "securepassword"
    )

    assert result.failure?
    assert result.is?(:email_already_taken)
  end
end
```

### Testing with Dependency Injection

Inject mock dependencies to test in isolation:

```ruby
class UserCreationTest < ActiveSupport::TestCase
  test "sends welcome email on success" do
    # Create a mock mailer that tracks calls
    mock_mailer = Minitest::Mock.new
    mock_mailer.expect(:welcome, OpenStruct.new(deliver_later: true), [User])

    result = User::Creation.new(mailer: mock_mailer).call(
      name: "Alice",
      email: "alice@example.com",
      password: "securepassword",
      password_confirmation: "securepassword"
    )

    assert result.success?
    mock_mailer.verify
  end
end
```

### Testing Nested Processes

Inject fake inner processes to test outer processes in isolation:

```ruby
class AccountOwnerCreationTest < ActiveSupport::TestCase
  test "creates account when user creation succeeds" do
    # Create a fake user creation process
    fake_user_creation = ->(params) {
      user = User.create!(params)
      Solid::Success(:user_created, user: user, token: "fake-token")
    }

    result = Account::OwnerCreation.new(user_creation: fake_user_creation).call(
      uuid: SecureRandom.uuid,
      owner: { name: "Alice", email: "alice@example.com", password: "password", password_confirmation: "password" }
    )

    assert result.success?
    assert result.is?(:account_owner_created)
  end

  test "fails when user creation fails" do
    # Create a fake that always fails
    fake_user_creation = ->(params) {
      Solid::Failure(:email_already_taken)
    }

    result = Account::OwnerCreation.new(user_creation: fake_user_creation).call(
      uuid: SecureRandom.uuid,
      owner: { name: "Alice", email: "alice@example.com", password: "password", password_confirmation: "password" }
    )

    assert result.failure?
    assert result.is?(:invalid_owner)
  end
end
```

### Testing Input Validation

Test validation rules directly on the input class:

```ruby
class UserCreationInputTest < ActiveSupport::TestCase
  test "validates email format" do
    input = User::Creation.input.new(
      name: "Alice",
      email: "not-an-email",
      password: "password",
      password_confirmation: "password"
    )

    assert input.invalid?
    assert_includes input.errors[:email], "is invalid"
  end

  test "normalizes email" do
    input = User::Creation.input.new(
      name: "Alice",
      email: "  ALICE@EXAMPLE.COM  ",
      password: "password",
      password_confirmation: "password"
    )

    input.valid?  # Triggers before_validation

    assert_equal "alice@example.com", input.email
  end
end
```

### Testing Callbacks

Verify that callbacks execute as expected:

```ruby
class PersonCreationTest < ActiveSupport::TestCase
  test "logs creation on success" do
    logged_messages = []

    # Temporarily replace the logger
    original_logger = Rails.logger
    Rails.logger = Logger.new(StringIO.new).tap do |logger|
      logger.define_singleton_method(:info) { |msg| logged_messages << msg }
    end

    PersonCreation.call(name: "Alice", email: "alice@example.com")

    assert logged_messages.any? { |msg| msg.include?("Created person") }
  ensure
    Rails.logger = original_logger
  end
end
```

### Testing with RSpec

The same patterns work with RSpec:

```ruby
RSpec.describe User::Creation do
  describe ".call" do
    context "with valid input" do
      it "creates a user" do
        result = described_class.call(
          name: "Alice",
          email: "alice@example.com",
          password: "securepassword",
          password_confirmation: "securepassword"
        )

        expect(result).to be_success
        expect(result.type).to eq(:user_created)
        expect(result[:user].name).to eq("Alice")
      end
    end

    context "with mocked dependencies" do
      let(:mock_mailer) { instance_double(UserMailer) }

      it "sends welcome email" do
        allow(mock_mailer).to receive(:welcome).and_return(double(deliver_later: true))

        result = described_class.new(mailer: mock_mailer).call(
          name: "Alice",
          email: "alice@example.com",
          password: "securepassword",
          password_confirmation: "securepassword"
        )

        expect(mock_mailer).to have_received(:welcome)
      end
    end
  end
end
```

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

## What's Next?

You now have a comprehensive understanding of Solid::Process. Here are some paths forward:

1. **Start Simple** — Begin with basic processes (input + call + Success/Failure)
2. **Add Structure** — Use the Steps DSL when processes get complex
3. **Inject Dependencies** — Make processes testable with the deps block
4. **Compose Processes** — Build larger workflows from smaller processes
5. **Add Observability** — Enable instrumentation for debugging

Remember the mantra: **Make it Work, Make it Better, Make it Even Better.**

For real-world examples, check:

- [examples/business_processes](../examples/business_processes/) — User registration flow
- [Solid Rails App](https://github.com/solid-process/solid-rails-app) — Complete Rails application

For questions or issues, visit the [GitHub repository](https://github.com/solid-process/solid-process).

<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>

---

<small>

`Previous` [README](../README.md#-table-of-contents-) | `Next` [Quick Overview](overview/010_KEY_CONCEPTS.md)

</small>
