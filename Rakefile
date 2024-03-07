# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs += %w[lib test]

  t.test_files = FileList.new("test/**/*_test.rb")
end

require "appraisal/task"

Appraisal::Task.new

require "standard/rake"

task default: %i[test standard]
