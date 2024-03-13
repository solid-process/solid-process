# frozen_string_literal: true

require "test_helper"
require "solid/validators/persisted_validator"

class Solid::PersistedValidatorTest < ActiveSupport::TestCase
  class Input < Solid::Input
    attribute :obj1
    attribute :obj2
    attribute :obj3

    validates :obj1, persisted: true
    validates :obj2, persisted: true
    validates :obj3, persisted: true, allow_nil: true
  end

  test "persisted validator" do
    input = Input.new

    input.obj1 = OpenStruct.new(persisted?: true)
    input.obj2 = OpenStruct.new(persisted?: true)
    input.obj3 = OpenStruct.new(persisted?: true)

    assert_predicate input, :valid?

    input.obj1 = OpenStruct.new(persisted?: false)
    input.obj2 = OpenStruct.new(persisted?: false)
    input.obj3 = OpenStruct.new(persisted?: false)

    refute_predicate input, :valid?

    assert_equal ["must be persisted"], input.errors[:obj1]
    assert_equal ["must be persisted"], input.errors[:obj2]
    assert_equal ["must be persisted"], input.errors[:obj3]

    input.obj1 = nil
    input.obj2 = nil
    input.obj3 = nil

    refute_predicate input, :valid?

    assert_equal ["must be persisted"], input.errors[:obj1]
    assert_equal ["must be persisted"], input.errors[:obj2]
    assert_empty input.errors[:obj3]

    input.obj1 = OpenStruct.new(persisted?: true)
    input.obj2 = OpenStruct.new(persisted?: true)

    assert_predicate input, :valid?
  end
end
