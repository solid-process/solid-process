# frozen_string_literal: true

require "test_helper"

class Solid::ValueAccessTest < ActiveSupport::TestCase
  class UUID
    include Solid::Value

    attribute default: -> { SecureRandom.uuid }

    attribute :string
  end

  test "#[]" do
    uuid = UUID.new

    assert_match(TestUtils::UUID_REGEX, uuid[:value])
    assert_match(TestUtils::UUID_REGEX, uuid["value"])
  end

  test "#value" do
    uuid = UUID.new("some-string")

    slice = uuid.slice(:value)

    assert_equal({"value" => uuid.value}, slice)

    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, slice)
  end

  test "#values_at" do
    uuid = UUID.new("some-string")

    assert_equal([uuid.value], uuid.values_at(:value))

    assert_empty(uuid.values_at)
    assert_instance_of(Array, uuid.values_at)
  end
end
