<small>

`Previous` [Internal Libraries](./090_INTERNAL_LIBRARIES.md) | `Next` [Table of Contents](../README.md#further-reading)

</small>

# Ports and Adapters

Use Solid::Process with hexagonal architecture to isolate business logic from external systems.

## Conceptual Structure

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Core                         │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Solid::Process                          │    │
│  │  (Business Logic / Use Cases)                        │    │
│  └─────────────────────────────────────────────────────┘    │
│           │                           │                      │
│     [Ports: deps]              [Ports: deps]                 │
│           │                           │                      │
└───────────┼───────────────────────────┼──────────────────────┘
            │                           │
   ┌────────▼────────┐         ┌────────▼────────┐
   │    Adapters     │         │    Adapters     │
   │  (Repository,   │         │  (Mailer, API   │
   │   Gateway)      │         │   Client)       │
   └─────────────────┘         └─────────────────┘
```

## Quick Example

```ruby
# Port: Define the interface via deps
class Order::Creation < Solid::Process
  deps do
    attribute :repository, default: OrderRepository
    attribute :payment_gateway, default: StripeGateway
    attribute :notifier, default: OrderNotifier

    validates :payment_gateway, respond_to: :charge
  end

  input do
    attribute :items, :array
    attribute :customer_id, :integer
  end

  def call(attributes)
    order = deps.repository.create!(attributes)          # Direct method
    result = deps.payment_gateway.call(order:)           # Process call
    deps.notifier.with(order:).placed.deliver_later      # Mailer pattern

    Success(:order_created, order:)
  end
end

# Adapters: Swap implementations for different contexts
Order::Creation.new(
  repository: InMemoryOrderRepository.new,
  payment_gateway: FakePaymentGateway.new,
  notifier: NullNotifier.new
).call(items: [...], customer_id: 1)
```

## Key Points

- **Ports** are defined via `deps` — abstract interfaces the process depends on
- **Adapters** are the concrete implementations (repositories, gateways, notifiers)
- Validate adapter contracts with `validates :dep, respond_to: :method` (see [Validators Reference](./000_GETTING_STARTED.md#14-validators-reference))
- Swap adapters at instantiation: production, test, or alternative implementations
- Business logic in processes stays pure and testable
- External systems (databases, APIs, email) are accessed only through adapters

## Learn More

For detailed explanations, examples, and advanced patterns, see:

- [Dependencies](./000_GETTING_STARTED.md#9-dependencies) — defining and injecting dependencies
- [Process Composition](./000_GETTING_STARTED.md#10-process-composition) — composing processes
- [Validators Reference](./000_GETTING_STARTED.md#14-validators-reference) — all built-in validators
