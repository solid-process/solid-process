## [Unreleased]

## [0.6.0] - 2026-01-28

### Added

- Add conditional `normalizes` support to `Solid::Model` (requires Rails 8.1+ with `ActiveModel::Attributes::Normalization`).

- Add `normalizes` to `Solid::Value`, automatically prepending `:value` as the attribute name.

## [0.5.0] - 2025-01-27

### Added

- Add support for Ruby 3.4 and 4.x.

- Add support for Rails 7.2, 8.0, and 8.1.

### Fixed

- Fix `BacktraceCleaner::BLOCKS_PATTERN` to handle Ruby 4.x backtrace format (`'Kernel#then'` instead of `` `then' ``).

## [0.4.0] - 2024-06-23

### Added

- Add `Solid::Process.configuration(freeze: true)`.

- Add `Solid::Process::EventLogs::BasicLoggerListener`.

- Add `Solid::Process::BacktraceCleaner`.

- Add `Solid::Process.configure` as an alias to `Solid::Process.configuration`.

- Add `Solid::Value` to allow defining a value object.

- `Solid::Model`
  - Add `after_initialize` callback.
  - Add `#[]` to access instance attributes.

- `solid/validators`
  - Add `id_validator`, to check if the value is a positive integer or a string that represents a positive integer.
  - Add `is_validator`, to check if the value satisfy the given predicate methods.

### Changed

- Replace the usage of `deep_symbolize_keys` with `symbolize_keys` to perform the call more efficiently.

- Change `email_validator` and `uuid_validator` to use `I18n` messages.

- Relax `ActiveModel` dependency to `>= 6.0`.

### Removed

- Remove some validators:
  - `bool_validator`
  - `is_a_validator`
  - `persisted_validator`

## [0.3.0] - 2024-04-14

### Changed

- Replace `bcdd-result` gem `solid-result` gem. This change removes the constant aliases `Solid::Output` and `Solid::Result`, as they are no longer needed.

## [0.2.0] - 2024-03-18

### Added

- Add `Solid::Process#success?`, `Solid::Process#failure?` that delegate to `Solid::Process#output.success?` and `Solid::Process#output.failure?`.

- Add `Solid::Process#with` method to create a new process instance with new dependencies.

- Add `Solid::Process#new` method. It's similar to `Solid::Process#with` but does not require passing the dependencies. If nothing is passed, it will use the same dependencies.

- Add `rescue_from` (from `::ActiveSupport::Rescuable`) method to `Solid::Process` to rescue exceptions and return a `Solid::Output`.

- Add `Solid::Process.config` and `Solid::Process.configuration` methods to define a configuration for all processes.

### Changed

- Move `Solid::Input` features to `Solid::Model` module. This change does not promote breaking changes.

## [0.1.0] - 2024-03-16

### Added

- Add `Solid::Model` module to define a model with attributes and validations.
  - It includes `ActiveModel::Api`, `ActiveModel::Access`, `ActiveModel::Attributes`, `ActiveModel::Dirty`, `ActiveModel::Validations::Callbacks`.

- Add `Solid::Input` class (which includes `Solid::Model`) to define an input object with attributes and validations.

- Add `Solid::Output` and `Solid::Result` as constant aliases of `BCDD::Context`.

- Add `Solid::Success()` and `Solid::Failure()` methods to create `BCDD::Context` instances.

- Add `Solid::Process` class to be inherited and define a process with inputs, outputs, and steps.

- Add several ActiveModel validations to be used in `Solid::Model` and `Solid::Input` classes.
  - `bool_validator`
  - `email_validator`
  - `instance_of_validator`
  - `is_a_validator`
  - `kind_of_validator`
  - `persisted_validator`
  - `respond_to_validator`
  - `singleton_validator`
  - `uuid_validator`
