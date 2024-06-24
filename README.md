<p align="center">
  <h1 align="center" id="-solidprocess">⚛️ Solid::Process</h1>
  <p align="center"><i>Write business logic for Ruby/Rails that scales.</i></p>
  <p align="center">
    <a href="https://codeclimate.com/github/solid-process/solid-process/maintainability"><img src="https://api.codeclimate.com/v1/badges/643a53e99bb591321c9f/maintainability" /></a>
    <a href="https://codeclimate.com/github/solid-process/solid-process/test_coverage"><img src="https://api.codeclimate.com/v1/badges/643a53e99bb591321c9f/test_coverage" /></a>
    <img src="https://img.shields.io/badge/Ruby%20%3E%3D%202.7%2C%20%3C%3D%20Head-ruby.svg?colorA=444&colorB=333" alt="Ruby">
    <img src="https://img.shields.io/badge/Rails%20%3E%3D%206.0%2C%20%3C%3D%20Edge-rails.svg?colorA=444&colorB=333" alt="Rails">
  </p>
</p>

## 📚 Table of Contents <!-- omit from toc -->

- [Supported Ruby and Rails](#supported-ruby-and-rails)
- [Introduction](#introduction)
- [Installation](#installation)
- [The Mental Model](#the-mental-model)
- [The Basic Structure](#the-basic-structure)
  - [Calling a Process](#calling-a-process)
- [Further Reading](#further-reading)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Supported Ruby and Rails

This library is tested (100% coverage) against:

| Ruby / Rails | 6.0 | 6.1 | 7.0 | 7.1 | Edge |
|--------------|-----|-----|-----|-----|------|
| 2.7          | ✅  | ✅  | ✅  | ✅   |      |
| 3.0          | ✅  | ✅  | ✅  | ✅   |      |
| 3.1          | ✅  | ✅  | ✅  | ✅   | ✅   |
| 3.2          | ✅  | ✅  | ✅  | ✅   | ✅   |
| 3.3          | ✅  | ✅  | ✅  | ✅   | ✅   |
| Head         |    |     |     | ✅   | ✅   |

## Introduction

`solid-process` is a Ruby/Rails library designed to encapsulate business logic into manageable processes. It simplifies writing, testing, maintaining, and evolving your code, ensuring it remains clear and approachable as your application scales.

**Key Objectives:**

1. **Seamless Rails integration:** Designed to complement Ruby on Rails, this library integrates smoothly without conflicting with existing framework conventions and features.

2. **Support progressive mastery:** Offers an intuitive entry point for novices while providing robust, advanced features that cater to experienced developers.

3. **Promote conceptual integrity and rapid onboarding:** By maintaining a consistent design philosophy, `solid-process` reduces the learning curve for new developers, allowing them to contribute more effectively and quickly to a codebase.

4. **Enhanced observability:** Equipped with sophisticated instrumentation mechanisms, the library enables detailed logging and tracing without compromising code readability, even when processes are nested.

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

### Examples <!-- omit in toc -->

Take a look at the [examples](examples) folder in this repository. Or check out [Solid Rails App](https://github.com/solid-process/solid-rails-app) for a complete example of how to use `solid-process` in a Rails application. [Twelve versions (branches)](https://github.com/solid-process/solid-rails-app?tab=readme-ov-file#-repository-branches) show how the gem can be incrementally integrated. Access it to see from simple services/form objects to implementing the ports and adapters (hexagonal) architectural pattern.

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add solid-process

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install solid-process

And require it in your code:

    require 'solid/process'

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## The Mental Model

### What is a process? <!-- omit from toc -->

A sequence of steps or actions to achieve a specific end. In other words, it is a series of steps that produce a result.

### What is a `Solid::Process`? <!-- omit from toc -->

It is a class that encapsulates reusable business logic. Its main goal is to **act as an orchestrator** who knows the order, what to use, and the steps necessary to produce an expected result.

### Emergent Design <!-- omit from toc -->

The business rule is directly coupled with business needs. We are often unclear about these rules and how they will be implemented as code. Clarity tends to improve over time and after many maintenance cycles.

For this reason, this abstraction embraces emerging design, allowing developers to implement code in a basic structure that can evolve and become sophisticated through the learnings obtained over time.

### The Mantra <!-- omit from toc -->

* **Make it Work**, then
* **Make it Better**, then
* **Make it Even Better**.

Using the emerging design concept, I invite you to embrace this development cycle, write the minimum necessary to implement processes and add more solid-process features based on actual needs.

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## The Basic Structure

All `Solid::Process` requires at least two things: an `input` and a `call` method.

1. The `input` is a set of attributes needed to perform the work.
2. The `#call` method is the entry point and where the work is done.
  - It receives the attributes Hash (symbolized keys), defined by the `input`.
  - It returns a `Success` or `Failure` as the output.

```ruby
class User::Creation < Solid::Process
  input do
    # Define the attributes needed to perform the work
  end

  def call(attributes)
    # Perform the work and return a Success or Failure as the output
  end
end
```

#### Example <!-- omit in toc -->

```ruby
class User::Creation < Solid::Process
  input do
    attribute :email
    attribute :password
    attribute :password_confirmation
  end

  def call(attributes)
    user = User.create(attributes)

    if user.persisted?
      Success(:user_created, user: user)
    else
      Failure(:user_not_created, user: user)
    end
  end
end
```

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

### Calling a Process

To call a process, you can use the `call` method directly, or instantiate the class and call the `#call` method.

```ruby
###############
# Direct call #
###############

User::Creation.call(email: 'john.doe@email.com', password: 'password', password_confirmation: 'password')
# => #<Solid::Output::Success type=:user_created value={:user=>#<User id: 1, ...>}>

########################
# Instantiate and call #
########################

process = User::Creation.new

process.call(email: 'john.doe@email.com', password: 'password', password_confirmation: 'password')
```

For now, it's essential to know that a process instance is stateful, and because of this, you can call it only once.

```ruby
process = User::Creation.new

input = {email: 'john.doe@email.com', password: 'password', password_confirmation: 'password'}

process.call(input)

process.call(input)
# The `User::Creation#output` is already set. Use `.output` to access the result or create a new instance to call again. (Solid::Process::Error)
```

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## Further Reading

- [01 - Basic Usage](docs/01_BASIC_USAGE.md)
- [02 - Intermediate Usage](docs/02_INTERMEDIATE_USAGE.md)
- [03 - Advanced Usage](docs/03_ADVANCED_USAGE.md)
- [04 - Error Handling](docs/04_ERROR_HANDLING.md)
- [05 - Testing](docs/05_TESTING.md)
- [06 - Instrumentation / Observability](docs/06_INSTRUMENTATION.md)
- [07 - Rails Integration](docs/07_RAILS_INTEGRATION.md)
- [08 - Internal libraries](docs/08_INTERNAL_LIBRARIES.md)
  - Solid::Input
  - Solid::Model
  - Solid::Value
  - ActiveModel validations
- [09 - Ports and Adapters (Hexagonal Architecture)](docs/09_PORTS_AND_ADAPTERS.md)

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake dev` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solid-process/solid-process. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/solid-process/solid-process/blob/main/CODE_OF_CONDUCT.md).

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## Code of Conduct

Everyone interacting in the Solid::Process project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/solid-process/solid-process/blob/main/CODE_OF_CONDUCT.md).

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>
