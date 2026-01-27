# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs += %w[lib test]

  t.test_files = FileList.new("test/**/*_test.rb")
end

require "appraisal/task"

Appraisal::Task.new

require "standard/rake" if RUBY_VERSION >= "3.4"

desc "Run the full test suite in all supported Rails versions"
task :matrix do
  if RUBY_VERSION < "3.1"
    system "bundle exec appraisal rails-6-0 rake test"
    system "bundle exec appraisal rails-6-1 rake test"
  end

  if RUBY_VERSION > "3.0" && RUBY_VERSION < "3.4.0"
    system "bundle exec appraisal rails-7-0 rake test"
    system "bundle exec appraisal rails-7-1 rake test"
  end

  if RUBY_VERSION >= "3.1.0" && RUBY_VERSION < "4.0.0"
    system "bundle exec appraisal rails-7-2 rake test"
  end

  if RUBY_VERSION >= "3.2.0" && RUBY_VERSION < "4.0.0"
    system "bundle exec appraisal rails-8-0 rake test"
  end

  if RUBY_VERSION >= "3.3.0"
    system "bundle exec appraisal rails-8-1 rake test"
    system "bundle exec appraisal rails-edge rake test"
  end

  Rake::Task[:standard].invoke if RUBY_VERSION >= "3.4"
end
