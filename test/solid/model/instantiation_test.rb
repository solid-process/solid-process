# frozen_string_literal: true

require "test_helper"

class Solid::ModelInstantiationTest < ActiveSupport::TestCase
  class MyModel < Solid::Input
    attribute :uuid, :string, default: -> { SecureRandom.uuid }
  end

  test "the new alias" do
    uuid = SecureRandom.uuid

    model1 = MyModel[]
    model2 = MyModel[uuid: uuid]

    assert_match TestUtils::UUID_REGEX, model1.uuid
    assert_equal uuid, model2.uuid
  end
end
