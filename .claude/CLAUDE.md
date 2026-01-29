# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`solid-process` is a Ruby gem for encapsulating business logic into manageable processes. It integrates with Rails and provides input validation, dependency injection, and observability features.

## Documentation

- **[docs/REFERENCE.md](docs/REFERENCE.md)** — Comprehensive guide covering every feature with detailed examples. Point AI coding agents here.
- **[docs/overview/](docs/overview/)** — Quick overview guides (010–100) for each topic.

### Back-to-Top Anchors

Both `README.md` and `docs/REFERENCE.md` use back-to-top navigation after each main section. When adding a new numbered section to `REFERENCE.md`:

1. Add `<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>` before the `---` that closes the section
2. Update the Table of Contents with the new entry

### Overview File Structure

Each file in `docs/overview/` follows this layout:

1. **Header nav** — `<small>` block with `` `Previous` `` and `` `Next` `` links
2. **`---`** separator
3. **Content** — starts with a `#` title
4. **`---`** separator
5. **Footer nav** — `<small>` block with the same `` `Previous` ``/`` `Next` `` links as the header

Navigation chain: `010_KEY_CONCEPTS` → `020_BASIC_USAGE` → … → `100_PORTS_AND_ADAPTERS`. The first file's `Previous` links to `../README.md#further-reading`; the last file's `Next` links to `../REFERENCE.md`.

When adding a new overview file:

1. Follow the numbered naming convention (e.g., `110_NEW_TOPIC.md`)
2. Add header and footer nav blocks with `---` separators
3. Update the `Previous`/`Next` links in the adjacent files to include the new file

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

### Ruby/Rails Version Alignment

When modifying Ruby or Rails version support, ensure these files stay aligned:

| File | Purpose |
|------|---------|
| `Appraisals` | Source of truth for gem dependencies per Rails version |
| `Rakefile` | Local `rake matrix` task conditions |
| `.github/workflows/main.yml` | CI matrix and step conditions |
| `README.md` | Compatibility matrix table |

**Key checks:**
1. Ruby version conditions must match across `Appraisals`, `Rakefile`, and CI
2. CI string values (e.g., `'head'`) need explicit checks since numeric comparisons won't match them
3. README table must reflect the actual tested combinations
4. Ruby `head` should only run against Rails edge (not stable Rails versions)

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
