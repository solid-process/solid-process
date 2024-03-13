# frozen_string_literal: true

require "test_helper"
require "solid/validators/singleton_validator"

class Solid::SingletonValidatorTest < ActiveSupport::TestCase
  class MyString < String
  end

  module MyEnumerable
    include Enumerable
  end

  class Input < Solid::Input
    attribute :mod_or_class1
    attribute :mod_or_class2
    attribute :mod_or_class3

    validates :mod_or_class1, singleton: String
    validates :mod_or_class2, singleton: [String, Symbol]
    validates :mod_or_class3, singleton: [Enumerable], allow_nil: true
  end

  test "singleton validator" do
    input = Input.new

    input.mod_or_class1 = MyString
    input.mod_or_class2 = MyString
    input.mod_or_class3 = MyEnumerable

    assert_predicate input, :valid?

    input.mod_or_class1 = Integer
    input.mod_or_class2 = Integer
    input.mod_or_class3 = Integer

    refute_predicate input, :valid?

    assert_equal ["is not String"], input.errors[:mod_or_class1]
    assert_equal ["is not String | Symbol"], input.errors[:mod_or_class2]
    assert_equal ["is not Enumerable"], input.errors[:mod_or_class3]

    input.mod_or_class1 = nil
    input.mod_or_class2 = nil
    input.mod_or_class3 = nil

    refute_predicate input, :valid?

    assert_equal ["is not a class or module"], input.errors[:mod_or_class1]
    assert_equal ["is not a class or module"], input.errors[:mod_or_class2]
    assert_empty input.errors[:mod_or_class3]

    input.mod_or_class1 = String
    input.mod_or_class2 = Symbol

    assert_predicate input, :valid?

    err2 = assert_raises(ArgumentError) do
      klass = Class.new(Solid::Input) do
        attribute :mod_or_class

        validates :mod_or_class, singleton: "String"

        def self.name
          "Input"
        end
      end

      klass.new(mod_or_class: String).valid?
    end

    assert_equal "\"String\" is not a class or module", err2.message
  end
end
