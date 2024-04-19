# frozen_string_literal: true

require "test_helper"
require "solid/validators/is_validator"

class Solid::IsValidatorTest < ActiveSupport::TestCase
  class Input < Solid::Input
    attribute :obj1
    attribute :obj2
    attribute :obj3

    validates :obj1, is: [:present?, :persisted?]
    validates :obj2, is: :persisted?
    validates :obj3, is: :persisted?, allow_nil: true
  end

  class InvalidValidationArg < Solid::Input
    attribute :obj

    validates :obj, is: :persisted
  end

  test "is validator" do
    input = Input.new

    input.obj1 = OpenStruct.new(present?: true, persisted?: true)
    input.obj2 = OpenStruct.new(present?: false, persisted?: true)
    input.obj3 = OpenStruct.new(present?: false, persisted?: true)

    assert_predicate input, :valid?

    input.obj1 = OpenStruct.new(present?: true, persisted?: false)
    input.obj2 = OpenStruct.new(persisted?: false)
    input.obj3 = OpenStruct.new(persisted?: false)

    refute_predicate input, :valid?

    assert_equal ["does not satisfy the predicates: present? & persisted?"], input.errors[:obj1]
    assert_equal ["does not satisfy the predicate: persisted?"], input.errors[:obj2]
    assert_equal ["does not satisfy the predicate: persisted?"], input.errors[:obj3]

    input.obj1 = nil
    input.obj2 = nil
    input.obj3 = nil

    refute_predicate input, :valid?

    assert_equal ["does not satisfy the predicates: present? & persisted?"], input.errors[:obj1]
    assert_equal ["does not satisfy the predicate: persisted?"], input.errors[:obj2]
    assert_empty input.errors[:obj3]

    input.obj1 = OpenStruct.new(present?: true, persisted?: true)
    input.obj2 = OpenStruct.new(persisted?: true)

    assert_predicate input, :valid?
  end

  test "raises error when receive invalid validation argument" do
    exception = assert_raises ArgumentError do
      InvalidValidationArg.new.valid?
    end

    assert_equal "expected a predicate method, got :persisted", exception.message
  end
end
