# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`solid-process` is a Ruby gem for encapsulating business logic into manageable processes. It integrates with Rails and provides input validation, dependency injection, and observability features.

## Common Commands

```bash
# Setup (install dependencies: bundle + appraisal)
bin/setup

# Clean install + full test suite. Useful when switching Ruby versions.
bin/matrix

# Run all tests for current Ruby version
bin/rake matrix

# Run a single test file
bundle exec appraisal rails-8-1 ruby -Ilib:test test/solid/process/result_test.rb

# Run a specific test by name
bundle exec appraisal rails-8-1 ruby -Ilib:test test/solid/process/result_test.rb -n test_method_name

# Interactive console
bin/console
```

## Lint

**Ensure lint is green before committing.**

```bash
# Check for style violations (Ruby 3.4+)
bin/rake standard

# Auto-fix style violations
bin/rake standard:fix
```

### Release Checklist

When `lib/solid/process/version.rb` is changed:
1. Verify `CHANGELOG.md` has a matching version entry (e.g., `## [0.5.0] - YYYY-MM-DD`)
2. Verify `README.md` compatibility matrix is up-to-date if Ruby/Rails support changed

## Switching Ruby Versions

### ASDF

```bash
asdf list ruby        # List installed Ruby versions
asdf set ruby 4.0.1   # Ruby 4.x
```

## Tests

Always test on multiple Ruby versions when fixing compatibility issues.

### Support Files

Test fixtures in `test/support/` follow numbered naming (e.g., `051_user_token_creation.rb`) for load order. These define sample processes used across multiple tests.

### Fix Library Code, Not Tests

When tests fail due to Ruby version differences:
1. First check if the **library code** can be updated to normalize behavior
2. Only modify tests if the library fix isn't possible

### Available Rails versions (see Rakefile for full list)
```sh
bundle exec appraisal rails-6-0 rake test # Ruby 2.7, 3.0
bundle exec appraisal rails-6-1 rake test # Ruby 2.7, 3.0
bundle exec appraisal rails-7-0 rake test # Ruby 3.0, 3.1, 3.2, 3.3
bundle exec appraisal rails-7-1 rake test # Ruby 3.0, 3.1, 3.2, 3.3
bundle exec appraisal rails-7-2 rake test # Ruby 3.1, 3.2, 3.3, 3.4
bundle exec appraisal rails-8-0 rake test # Ruby 3.2, 3.3, 3.4
bundle exec appraisal rails-8-1 rake test # Ruby 3.3, 3.4, 4.x
```

## Architecture

### Core Classes

- **Solid::Process** (`lib/solid/process.rb`) - Base class for business processes. Requires `input` block and `call` method. Returns `Success` or `Failure` outputs.

- **Solid::Model** (`lib/solid/model.rb`) - ActiveModel-based concern providing attributes, validations, and callbacks.

- **Solid::Input** (`lib/solid/input.rb`) - Input validation class, includes Solid::Model.

- **Solid::Value** (`lib/solid/value.rb`) - Immutable value objects.

- **Solid::Output** (`lib/solid/output.rb`) - Wraps solid-result gem for Success/Failure return types.
