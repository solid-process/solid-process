# frozen_string_literal: true

require_relative "lib/solid/process/version"

Gem::Specification.new do |spec|
  spec.name = "solid-process"
  spec.version = Solid::Process::VERSION
  spec.authors = ["Rodrigo Serradura"]
  spec.email = ["rodrigo.serradura@gmail.com"]

  spec.summary = "Ruby on Rails + Business Processes"
  spec.description = "Ruby on Rails + Business Processes"
  spec.homepage = "https://github.com/serradura/solid-process"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/serradura/solid-process"
  spec.metadata["changelog_uri"] = "https://github.com/serradura/solid-process/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[
          .git .github appveyor
          bin/ test/ spec/ features/ coverage/ gemfiles/
          Gemfile Appraisals
          .rubocop.yml .standard.yml
        ])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "bcdd-result", "~> 1.0"
  spec.add_dependency "activemodel", ">= 6.0", "< 8.0"

  spec.add_development_dependency "appraisal", "~> 2.5"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
