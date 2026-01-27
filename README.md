<p align="center">
  <h1 align="center" id="-solidprocess">⚛️ Solid::Process</h1>
  <p align="center"><i>Write business logic for Ruby/Rails that scales.</i></p>
  <p align="center">
    <a href="https://qlty.sh/gh/solid-process/projects/solid-process"><img src="https://qlty.sh/gh/solid-process/projects/solid-process/maintainability.svg" alt="Maintainability" /></a>
    <a href="https://qlty.sh/gh/solid-process/projects/solid-process"><img src="https://qlty.sh/gh/solid-process/projects/solid-process/coverage.svg" alt="Code Coverage" /></a>
    <img src="https://img.shields.io/badge/Ruby%20%3E%3D%202.7%2C%20%3C%3D%20Head-ruby.svg?colorA=444&colorB=333" alt="Ruby">
    <img src="https://img.shields.io/badge/Rails%20%3E%3D%206.0%2C%20%3C%3D%20Edge-rails.svg?colorA=444&colorB=333" alt="Rails">
  </p>
</p>

## 📚 Table of Contents <!-- omit from toc -->

- [Introduction](#introduction)
- [Installation](#installation)
- [The Basic Structure](#the-basic-structure)
- [Further Reading](#further-reading)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)
- [Acknowledgments](#acknowledgments)
- [About](#about)

## Supported Ruby and Rails <!-- omit from toc -->

This library is tested (100% coverage) against:

| Ruby / Rails | 6.0 | 6.1 | 7.0 | 7.1 | 7.2 | 8.0 | 8.1 | Edge |
|--------------|-----|-----|-----|-----|-----|-----|-----|------|
| 2.7          | ✅  | ✅  | ✅  | ✅  |     |     |     |      |
| 3.0          | ✅  | ✅  | ✅  | ✅  |     |     |     |      |
| 3.1          |     |     | ✅  | ✅  | ✅  |     |     |      |
| 3.2          |     |     | ✅  | ✅  | ✅  | ✅  |     |      |
| 3.3          |     |     | ✅  | ✅  | ✅  | ✅  | ✅  | ✅   |
| 3.4          |     |     |     |     | ✅  | ✅  | ✅  | ✅   |
| 4.x          |     |     |     |     |     |     | ✅  | ✅   |

## Introduction

`solid-process` is a Ruby/Rails library designed to encapsulate business logic into manageable processes. It simplifies writing, testing, maintaining, and evolving your code, ensuring it remains clear and approachable as your application scales.

**Features:** (_touch to expand_)

<details><summary>1️⃣ <strong>Seamless Rails integration</strong></summary>

  > Designed to complement Ruby on Rails, this library integrates smoothly without conflicting with existing framework conventions and features.

</details>

<details><summary>2️⃣ <strong>Support progressive mastery</strong></summary>

  > Offers an intuitive entry point for novices while providing robust, advanced features that cater to experienced developers.

</details>

<details><summary>3️⃣ <strong>Promote conceptual integrity and rapid onboarding</strong></summary>

  > By maintaining a consistent design philosophy, `solid-process` reduces the learning curve for new developers, allowing them to contribute more effectively and quickly to a codebase.

</details>

<details><summary>4️⃣ <strong>Enhanced observability</strong></summary>

  > Equipped with sophisticated instrumentation mechanisms, the library enables detailed logging and tracing without compromising code readability, even when processes are nested.

</details>

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

### Examples <!-- omit in toc -->

Check out [Solid Rails App](https://github.com/solid-process/solid-rails-app) for a complete example of how to use `solid-process` in a Rails application. [Twelve versions (branches)](https://github.com/solid-process/solid-rails-app?tab=readme-ov-file#-repository-branches) show how the gem can be incrementally integrated, access it to see from simple services/form objects to implementing the ports and adapters (hexagonal) architectural pattern.

You can also check the [examples](examples) directory for more simple examples of how to use the gem.

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add solid-process

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install solid-process

And require it in your code:

    require 'solid/process'

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

### Calling a Process <!-- omit from toc -->

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

1. [Key Concepts](docs/010_KEY_CONCEPTS.md)
2. [Basic Usage](docs/020_BASIC_USAGE.md)
3. [Intermediate Usage](docs/030_INTERMEDIATE_USAGE.md)
4. [Advanced Usage](docs/040_ADVANCED_USAGE.md)
5. [Error Handling](docs/050_ERROR_HANDLING.md)
6. [Testing](docs/060_TESTING.md)
7. [Instrumentation / Observability](docs/070_INSTRUMENTATION.md)
8. [Rails Integration](docs/080_RAILS_INTEGRATION.md)
9. [Internal libraries](docs/090_INTERNAL_LIBRARIES.md)
  - Solid::Input
  - Solid::Model
  - Solid::Value
  - ActiveModel validations
10. [Ports and Adapters (Hexagonal Architecture)](docs/100_PORTS_AND_ADAPTERS.md)

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake matrix` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

```bash
# Run full test suite for current Ruby version
bin/rake matrix

# Run tests for a specific Rails version
bundle exec appraisal rails-8-1 rake test

# Run a single test file
bundle exec appraisal rails-8-1 ruby -Ilib:test test/solid/process/result_test.rb

# Lint (Ruby 3.4+)
bin/rake standard

# Clean install + full test suite (useful when switching Ruby versions)
# asdf set ruby <version>
bin/matrix
```

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

## Acknowledgments

I want to thank some people who helped me by testing and giving feedback as this project took shape, they are:

- [Diego Linhares](https://github.com/diegolinhares) and [Ralf Schmitz Bongiolo](https://github.com/mrbongiolo) they were the brave ones who worked for a few months with the first versions of the ecosystem (it was called B/CDD). Their feedback was essential for improving DX and helped me to pivot some core decisions.
- [Vitor Avelino](https://github.com/vitoravelino), [Tomás Coêlho](https://github.com/tomascco), [Haroldo Furtado](https://github.com/haroldofurtado) (I could repeat Ralf and Diego again) for the various feedbacks, documentation, API, support and words of encouragement.

## About

[Rodrigo Serradura](https://rodrigoserradura.com) created this project. He is the Solid Process creator and has already made similar gems like the [u-case](https://github.com/serradura/u-case) and [kind](https://github.com/serradura/kind). This gem can be used independently, but it also contains essential features that facilitate the adoption of Solid Process (the method) in code.

<p align="right"><a href="#-table-of-contents-">⬆️ &nbsp;back to top</a></p>
