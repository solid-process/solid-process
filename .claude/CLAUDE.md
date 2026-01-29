# CLAUDE.md

Ruby gem for encapsulating business logic into processes, with Rails integration, input validation, dependency injection, and observability.

## Commands

```bash
bin/setup              # Install dependencies (bundle + appraisal)
bin/rake matrix        # Run full test suite

# Single test file
bundle exec appraisal rails-8-1 ruby -Ilib:test test/solid/process/result_test.rb

# Single test by name (append -n test_method_name)
bundle exec appraisal rails-8-1 ruby -Ilib:test test/solid/process/result_test.rb -n test_method_name
```

## Lint

**Run `bin/rake standard` before committing.** Auto-fix with `bin/rake standard:fix`. Also ensure changes follow the conventions linked below.

## References

- **[docs/REFERENCE.md](../docs/REFERENCE.md)** — Full feature guide with detailed examples
- **[docs/overview/](../docs/overview/)** — Quick overview guides (010–100)

## Conventions

- **[Testing](docs/testing.md)** — Test fixtures, multi-version testing, Rails version matrix
- **[Documentation](docs/documentation.md)** — Back-to-top anchors, overview file structure
- **[Release & Versioning](docs/release-and-versioning.md)** — Release checklist, Ruby/Rails version alignment
