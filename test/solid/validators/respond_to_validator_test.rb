# frozen_string_literal: true

require "test_helper"
require "solid/validators/respond_to_validator"

class Solid::RespondToValidatorTest < ActiveSupport::TestCase
  class Input < Solid::Input
    attribute :object1
    attribute :object2

    validates :object1, respond_to: :to_sym, allow_nil: true
    validates :object2, respond_to: [:to_sym, :to_str]
  end

  test "respond_to validator" do
    input = Input.new

    input.object1 = "to_sym"
    input.object2 = "to_str"

    assert_predicate input, :valid?

    input.object1 = 1
    input.object2 = :to_sym

    refute_predicate input, :valid?

    assert_equal ["does not respond to :to_sym"], input.errors[:object1]
    assert_equal ["does not respond to :to_sym & :to_str"], input.errors[:object2]

    input.object1 = nil
    input.object2 = nil

    refute_predicate input, :valid?

    assert_empty input.errors[:object1]
    assert_equal ["does not respond to :to_sym & :to_str"], input.errors[:object2]

    input.object2 = "to_str"

    assert_predicate input, :valid?
  end
end
