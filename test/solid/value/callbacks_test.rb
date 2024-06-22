# frozen_string_literal: true

require "test_helper"

class Solid::ValueCallbacksTest < ActiveSupport::TestCase
  class MyValue
    include Solid::Value

    after_initialize do
      value[:after_initialize_value1] = "foo"
    end

    before_validation do
      value[:before_validation_value] = "bar"
    end

    after_validation do
      value[:after_validation_value] = "baz"
    end
  end

  test "the callbacks" do
    model = MyValue.new({})

    assert_equal("foo", model.value[:after_initialize_value1])
    assert_nil(model.value[:after_initialize_value2])
    assert_nil(model.value[:before_validation_value])
    assert_nil(model.value[:after_validation_value])

    model.valid?

    assert_equal("foo", model.value[:after_initialize_value1])
    assert_nil(model.value[:after_initialize_value2])
    assert_equal("bar", model.value[:before_validation_value])
    assert_equal("baz", model.value[:after_validation_value])
  end
end
