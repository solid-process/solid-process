# frozen_string_literal: true

require "test_helper"

class Solid::InputCallbacksTest < ActiveSupport::TestCase
  class MyInput < Solid::Input
    attribute :after_initialize_value1
    attribute :after_initialize_value2
    attribute :before_validation_value
    attribute :after_validation_value

    after_initialize do
      self.after_initialize_value1 = "foo"
    end

    before_validation do
      self.before_validation_value = "bar"
    end

    after_validation do
      self.after_validation_value = "baz"
    end
  end

  test "the callbacks" do
    input = MyInput.new

    assert_equal("foo", input.after_initialize_value1)
    assert_nil(input.after_initialize_value2)
    assert_nil(input.before_validation_value)
    assert_nil(input.after_validation_value)

    input.valid?

    assert_equal("foo", input.after_initialize_value1)
    assert_nil(input.after_initialize_value2)
    assert_equal("bar", input.before_validation_value)
    assert_equal("baz", input.after_validation_value)
  end
end
