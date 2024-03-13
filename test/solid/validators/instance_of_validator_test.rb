# frozen_string_literal: true

require "test_helper"
require "solid/validators/instance_of_validator"

class Solid::InstanceOfValidatorTest < ActiveSupport::TestCase
  class Input < Solid::Input
    attribute :symbol
    attribute :string
    attribute :to_sym

    validates :string, instance_of: String, allow_nil: true
    validates :symbol, instance_of: [Symbol]
    validates :to_sym, instance_of: [String, Symbol]
  end

  test "instance_of validator" do
    input = Input.new

    input.symbol = :symbol
    input.string = "string"
    input.to_sym = "to_sym"

    assert_predicate input, :valid?

    input.string = :symbol
    input.symbol = "string"
    input.to_sym = 1

    refute_predicate input, :valid?

    assert_equal ["is not an instance of String"], input.errors[:string]
    assert_equal ["is not an instance of Symbol"], input.errors[:symbol]
    assert_equal ["is not an instance of String | Symbol"], input.errors[:to_sym]

    input.string = nil
    input.symbol = nil
    input.to_sym = nil

    refute_predicate input, :valid?

    assert_empty input.errors[:string]
    assert_equal ["is not an instance of Symbol"], input.errors[:symbol]
    assert_equal ["is not an instance of String | Symbol"], input.errors[:to_sym]

    input.symbol = :symbol
    input.to_sym = :symbol

    assert_predicate input, :valid?
  end
end
