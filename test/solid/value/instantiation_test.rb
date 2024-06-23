# frozen_string_literal: true

require "test_helper"

class Solid::ValueInstantiationTest < ActiveSupport::TestCase
  class MyValue
    include Solid::Value

    attribute :string, default: -> { SecureRandom.uuid }
  end

  test "the new alias" do
    uuid_str = SecureRandom.uuid

    uuid1 = MyValue[]
    uuid2 = MyValue[uuid_str]

    assert_match TestUtils::UUID_REGEX, uuid1.value
    assert_equal uuid_str, uuid2.value
  end
end
