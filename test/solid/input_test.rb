# frozen_string_literal: true

require "test_helper"

class Solid::InputTest < ActiveSupport::TestCase
  test "is a Solid::Model" do
    assert_kind_of ::Class, Solid::Input

    assert Solid::Input < Solid::Model
  end
end
