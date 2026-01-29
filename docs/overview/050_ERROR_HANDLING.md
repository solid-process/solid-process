<small>

`Previous` [Advanced Usage](./040_ADVANCED_USAGE.md) | `Next` [Testing](./060_TESTING.md)

</small>

---

# Error Handling

Handle exceptions at the class level with `rescue_from` or at the method level with inline `rescue`.

## Class-Level: `rescue_from`

```ruby
class Division < Solid::Process
  input do
    attribute :numerator, :integer
    attribute :denominator, :integer
  end

  rescue_from ZeroDivisionError do |error|
    Failure!(:division_by_zero, error:)
  end

  def call(attributes)
    result = attributes[:numerator] / attributes[:denominator]

    Success(:calculated, result:)
  end
end

Division.call(numerator: 10, denominator: 0)
# => Failure(:division_by_zero)
```

## Class-Level: `rescue_from` with Method Handler

```ruby
rescue_from PaymentError, with: :handle_payment_error

private

def handle_payment_error(error)
  Failure!(:payment_failed, error:, code: error.code)
end
```

## Method-Level: Inline `rescue`

```ruby
# Option A: Convert exception to Failure (hard failure)
def create_user(email:, **)
  user = User.create!(email:)
  Continue(user:)
rescue ActiveRecord::RecordInvalid => e
  Failure(:creation_failed, errors: e.record.errors)
end

# Option B: Log and continue (soft failure for non-critical operations)
def send_notification(user:, **)
  NotificationService.notify(user)
  Continue()
rescue NotificationService::Error => e
  Rails.logger.error "Notification failed: #{e.message}"
  Continue()  # process continues despite error
end
```

## Converting Exceptions to Success (Idempotency)

```ruby
rescue_from ActiveRecord::RecordNotUnique do |e|
  existing = User.find_by(email: input.email)
  Success!(:already_exists, user: existing)
end
```

## Key Points

- Use `Failure!` (with bang) inside `rescue_from` handlers — not `Failure`
- `rescue_from` handles exceptions anywhere in the process
- Inline `rescue` gives per-method control over error handling
- You can specify a method handler: `rescue_from SomeError, with: :handle_error`
- Exceptions can be converted to `Success!` if appropriate (e.g., idempotency)

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Error Handling](../REFERENCE.md#12-error-handling) — complete error handling guide

---

<small>

`Previous` [Advanced Usage](./040_ADVANCED_USAGE.md) | `Next` [Testing](./060_TESTING.md)

</small>
