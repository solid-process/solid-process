<small>

`Previous` [Advanced Usage](./040_ADVANCED_USAGE.md) | `Next` [Testing](./060_TESTING.md)

</small>

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
    Failure!(:division_by_zero, error: error)
  end

  def call(attributes)
    result = attributes[:numerator] / attributes[:denominator]

    Success(:calculated, result: result)
  end
end

Division.call(numerator: 10, denominator: 0)
# => Failure(:division_by_zero)
```

## Method-Level: Inline `rescue`

```ruby
def create_user(email:, **)
  user = User.create!(email: email)
  Continue(user: user)
rescue ActiveRecord::RecordInvalid => e
  Failure(:creation_failed, errors: e.record.errors)
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

- [Error Handling](./000_GETTING_STARTED.md#12-error-handling) — complete error handling guide
