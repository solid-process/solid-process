# Testing Conventions

## Fix Library Code, Not Tests

When tests fail due to Ruby version differences:
1. First check if the **library code** can be updated to normalize behavior
2. Only modify tests if the library fix isn't possible

## Support Files

Test fixtures in `test/support/` follow numbered naming (e.g., `051_user_token_creation.rb`) for load order. These define sample processes used across multiple tests.

## Available Rails Versions

See `Rakefile` for the source of truth. Quick reference:

```sh
bundle exec appraisal rails-6-0 rake test # Ruby 2.7, 3.0
bundle exec appraisal rails-6-1 rake test # Ruby 2.7, 3.0
bundle exec appraisal rails-7-0 rake test # Ruby 3.0, 3.1, 3.2, 3.3
bundle exec appraisal rails-7-1 rake test # Ruby 3.0, 3.1, 3.2, 3.3
bundle exec appraisal rails-7-2 rake test # Ruby 3.1, 3.2, 3.3, 3.4
bundle exec appraisal rails-8-0 rake test # Ruby 3.2, 3.3, 3.4
bundle exec appraisal rails-8-1 rake test # Ruby 3.3, 3.4, 4.x
```
