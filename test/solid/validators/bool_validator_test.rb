# frozen_string_literal: true

require "test_helper"
require "solid/validators/bool_validator"

class Solid::BoolValidatorTest < ActiveSupport::TestCase
  class Input < Solid::Input
    attribute :value1
    attribute :value2

    validates :value1, bool: true
    validates :value2, bool: true, allow_nil: true
  end

  test "bool validator" do
    input = Input.new

    input.value1 = true
    input.value2 = false

    assert_predicate input, :valid?

    input.value1 = "true"
    input.value2 = "false"

    refute_predicate input, :valid?

    assert_equal ["is not a boolean"], input.errors[:value1]
    assert_equal ["is not a boolean"], input.errors[:value2]

    input.value1 = nil
    input.value2 = nil

    refute_predicate input, :valid?

    assert_equal ["is not a boolean"], input.errors[:value1]
    assert_empty input.errors[:value2]

    input.value1 = true

    assert_predicate input, :valid?
  end
end
