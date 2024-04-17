# frozen_string_literal: true

require "test_helper"
require "solid/validators/id_validator"

class Solid::IdValidatorTest < ActiveSupport::TestCase
  class Input < Solid::Input
    attribute :id1
    attribute :id2
    attribute :id3
    attribute :id4

    validates :id1, id: true
    validates :id2, id: true
    validates :id3, id: true, allow_nil: true
    validates :id4, id: true, allow_blank: true
  end

  test "id validator" do
    input = Input.new

    input.id1 = 1
    input.id2 = 2
    input.id3 = 3
    input.id4 = 4

    assert_predicate input, :valid?

    input.id1 = "1"
    input.id2 = "2"
    input.id3 = "3"
    input.id4 = "4"

    assert_predicate input, :valid?

    input.id1 = 0
    input.id2 = -1
    input.id3 = -2
    input.id4 = -3

    refute_predicate input, :valid?

    assert_equal ["must be greater than 0"], input.errors[:id1]
    assert_equal ["must be greater than 0"], input.errors[:id2]
    assert_equal ["must be greater than 0"], input.errors[:id3]
    assert_equal ["must be greater than 0"], input.errors[:id4]

    input.id1 = 1.0
    input.id2 = 2.0
    input.id3 = 3.0
    input.id4 = 4.0

    refute_predicate input, :valid?

    assert_equal ["must be an integer"], input.errors[:id1]
    assert_equal ["must be an integer"], input.errors[:id2]
    assert_equal ["must be an integer"], input.errors[:id3]
    assert_equal ["must be an integer"], input.errors[:id4]

    input.id1 = "1.0"
    input.id2 = "2.0"
    input.id3 = "3.0"
    input.id4 = "4.0"

    refute_predicate input, :valid?

    assert_equal ["must be an integer"], input.errors[:id1]
    assert_equal ["must be an integer"], input.errors[:id2]
    assert_equal ["must be an integer"], input.errors[:id3]
    assert_equal ["must be an integer"], input.errors[:id4]

    input.id1 = nil
    input.id2 = nil
    input.id3 = nil
    input.id4 = nil

    refute_predicate input, :valid?

    assert_equal ["is not a number"], input.errors[:id1]
    assert_equal ["is not a number"], input.errors[:id2]
    assert_empty input.errors[:id3]
    assert_empty input.errors[:id4]

    input.id1 = ""
    input.id2 = ""
    input.id3 = ""
    input.id4 = ""

    refute_predicate input, :valid?

    assert_equal ["is not a number"], input.errors[:id1]
    assert_equal ["is not a number"], input.errors[:id2]
    assert_equal ["is not a number"], input.errors[:id3]
    assert_empty input.errors[:id4]
  end
end
