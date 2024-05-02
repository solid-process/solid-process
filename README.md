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

## Supported Ruby and Rails

This library is tested against:

| Ruby / Rails | 6.0 | 6.1 | 7.0 | 7.1 | Edge |
|--------------|-----|-----|-----|-----|------|
| 2.7          | ✅  | ✅  | ✅  | ✅   |      |
| 3.0          | ✅  | ✅  | ✅  | ✅   |      |
| 3.1          | ✅  | ✅  | ✅  | ✅   | ✅   |
| 3.2          | ✅  | ✅  | ✅  | ✅   | ✅   |
| 3.3          | ✅  | ✅  | ✅  | ✅   | ✅   |
| Head         |    |    |    | ✅   | ✅   |

## Introduction

`solid-process` is a Ruby/Rails library designed to encapsulate business logic into manageable processes. It simplifies writing, testing, maintaining, and evolving your code, ensuring it remains clear and approachable as your application scales.

**Key Objectives:**

1. **Seamless Rails integration:** Designed to fully complement the Ruby on Rails framework, this library integrates smoothly without conflicting with existing Rails conventions and capabilities.

2. **Support progressive mastery:** Offers an intuitive entry point for novices while providing robust, advanced features that cater to experienced developers.

3. **Promote conceptual integrity and rapid onboarding:** By maintaining a consistent design philosophy, `solid-process` reduces the learning curve for new developers, allowing them to contribute more effectively and quickly.

4. **Minimize technical debt:** Facilitate smoother transitions and updates as your application expands and your team size increases.

5. **Enhanced observability:** Equipped with sophisticated instrumentation mechanisms, the library enables detailed logging and tracing without compromising clarity, even when processes are nested. This ensures the code is both easy to understand and to observe.

### Examples

Checkout the [solid-rails-app](https://github.com/solid-process/solid-rails-app) for a full example of how to use `solid-process` in a Rails application. Or take a look at the [examples](examples) folder in this repository.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solid-process'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install solid-process
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake dev` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solid-process/solid-process. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/solid-process/solid-process/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Solid::Process project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/solid-process/solid-process/blob/main/CODE_OF_CONDUCT.md).
