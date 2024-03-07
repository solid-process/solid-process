# frozen_string_literal: true

require "test_helper"

class Solid::ProcessVersionTest < ActiveSupport::TestCase
  test "that it has a version number" do
    refute_nil ::Solid::Process::VERSION
  end
end
