<small>

`Previous` [Error Handling](./050_ERROR_HANDLING.md) | `Next` [Instrumentation](./070_INSTRUMENTATION.md)

</small>

---

# Testing

Test processes by asserting on outcomes and using dependency injection to isolate units.

## Quick Example

```ruby
class UserCreationTest < ActiveSupport::TestCase
  test 'creates user with valid input' do
    result = User::Creation.call(
      name: 'Alice',
      email: 'alice@example.com',
      password: 'securepassword'
    )

    assert result.success?
    assert result.is?(:user_created)
    assert_equal 'Alice', result[:user].name
  end

  test 'fails with invalid email' do
    result = User::Creation.call(name: 'Alice', email: 'bad', password: 'pass')

    assert result.failure?
    assert result.is?(:invalid_input)
  end

  test 'uses injected dependencies' do
    mock_mailer = Minitest::Mock.new
    mock_mailer.expect(:welcome, OpenStruct.new(deliver_later: true), [User])

    result = User::Creation.new(mailer: mock_mailer).call(
      name: 'Alice',
      email: 'alice@example.com',
      password: 'securepassword'
    )

    assert result.success?
    mock_mailer.verify
  end

  test 'pattern matches on result' do
    result = User::Creation.call(name: 'Alice', email: 'alice@example.com', password: 'secure')

    case result
    in Solid::Success[:user_created, { user: }]
      assert_equal 'Alice', user.name
    else
      flunk 'Expected success(:user_created)'
    end
  end

  test 'normalizes email before validation' do
    input = User::Creation.input.new(email: '  ALICE@EXAMPLE.COM  ')
    input.valid?

    assert_equal 'alice@example.com', input.email
  end

  test 'mocks nested process' do
    fake_token_creation = ->(params) {
      Solid::Success(:token_created, token: 'test-token')
    }

    result = User::Creation.new(token_creation: fake_token_creation).call(
      name: 'Alice', email: 'alice@example.com', password: 'secure'
    )

    assert result.success?
  end
end
```

## Key Points

- Test the public interface: inputs and outputs
- Use `result.success?`, `result.failure?`, and `result.is?(:type)` for assertions
- Access result data via `result[:key]` (shorthand) or `result.value[:key]`
- Inject mock dependencies via `.new(dep: mock)` to test in isolation
- Test input validation separately on `MyProcess.input.new(...)`
- Fake nested processes to test outer processes independently
- Pattern matching works in test assertions (Ruby 3.0+)

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Testing](../REFERENCE.md#16-testing) — comprehensive testing patterns

---

<small>

`Previous` [Error Handling](./050_ERROR_HANDLING.md) | `Next` [Instrumentation](./070_INSTRUMENTATION.md)

</small>
