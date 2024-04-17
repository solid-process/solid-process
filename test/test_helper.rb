# frozen_string_literal: true

require "ostruct"
require "simplecov"

SimpleCov.start do
  enable_coverage :branch

  add_filter "/test/"
end

Bundler.require(:default, :test)

SimpleCov.command_name "test-rails-#{ActiveSupport.version.to_s.tr(".", "_")}"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |file| require file }

require "solid/process"

require "minitest/autorun"
require "active_support/test_case"

class ActiveSupport::TestCase
  parallelize(workers: 1)
end
