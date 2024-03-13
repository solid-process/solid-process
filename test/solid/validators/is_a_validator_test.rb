# frozen_string_literal: true

require "test_helper"
require "solid/validators/is_a_validator"

class Solid::IsAValidatorTest < ActiveSupport::TestCase
  class Input < Solid::Input
    attribute :to_sym
    attribute :number
    attribute :collection

    validates :to_sym, is_a: [String, Symbol]
    validates :number, is_a: Numeric
    validates :collection, is_a: Enumerable, allow_nil: true
  end

  test "is_a validator" do
    input = Input.new

    input.to_sym = "to_sym"
    input.number = 1
    input.collection = [1, 2, 3]

    assert_predicate input, :valid?

    input.to_sym = 1
    input.number = "1"
    input.collection = 1

    refute_predicate input, :valid?

    assert_equal ["is not a String | Symbol"], input.errors[:to_sym]
    assert_equal ["is not a Numeric"], input.errors[:number]
    assert_equal ["is not a Enumerable"], input.errors[:collection]

    input.to_sym = nil
    input.number = nil
    input.collection = nil

    refute_predicate input, :valid?

    assert_equal ["is not a String | Symbol"], input.errors[:to_sym]
    assert_equal ["is not a Numeric"], input.errors[:number]
    assert_empty input.errors[:collection]

    input.to_sym = :to_sym
    input.number = 1.0
    input.collection = {}

    assert_predicate input, :valid?

    input.collection = nil

    assert_predicate input, :valid?
  end
end
