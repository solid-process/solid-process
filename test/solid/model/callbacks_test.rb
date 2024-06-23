# frozen_string_literal: true

require "test_helper"

class Solid::ModelCallbacksTest < ActiveSupport::TestCase
  class MyModel
    include Solid::Model

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
    model = MyModel.new

    assert_equal("foo", model.after_initialize_value1)
    assert_nil(model.after_initialize_value2)
    assert_nil(model.before_validation_value)
    assert_nil(model.after_validation_value)

    model.valid?

    assert_equal("foo", model.after_initialize_value1)
    assert_nil(model.after_initialize_value2)
    assert_equal("bar", model.before_validation_value)
    assert_equal("baz", model.after_validation_value)
  end
end
