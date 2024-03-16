# frozen_string_literal: true

require "test_helper"

class Solid::InputInstantiationTest < ActiveSupport::TestCase
  class MyInput < Solid::Input
    attribute :uuid, :string, default: -> { SecureRandom.uuid }
  end

  test "the new alias" do
    uuid = SecureRandom.uuid

    input1 = MyInput[]
    input2 = MyInput[uuid: uuid]

    assert_match TestUtils::UUID_REGEX, input1.uuid
    assert_equal uuid, input2.uuid
  end
end
