# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in solid-process.gemspec
gemspec

gem "rake", "~> 13.3", ">= 13.3.1"

if RUBY_VERSION >= "3.4"
  gem "standard", "~> 1.53"
end

group :test do
  gem "bcrypt", "~> 3.1", ">= 3.1.21"

  gem "simplecov", "~> 0.22.0", require: false
end
