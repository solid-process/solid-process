# frozen_string_literal: true

require "test_helper"

class Solid::ValueTest < ActiveSupport::TestCase
  class MyUUID
    include Solid::Value

    attribute :string
  end

  test "is a Solid::Value" do
    assert MyUUID < Solid::Value
  end

  test "is a Solid::Model" do
    assert MyUUID < Solid::Model
  end

  test "#==" do
    uuid_str = SecureRandom.uuid

    assert_equal MyUUID.new(uuid_str), MyUUID.new(uuid_str)

    refute_equal uuid_str, MyUUID.new(uuid_str)
    refute_equal MyUUID.new(uuid_str), uuid_str
  end

  test "#eql?" do
    uuid_str = SecureRandom.uuid

    assert MyUUID.new(uuid_str).eql?(MyUUID.new(uuid_str))

    refute MyUUID.new(uuid_str).eql?(uuid_str)
  end

  test "#hash" do
    uuid_str = SecureRandom.uuid

    assert_equal uuid_str.hash, MyUUID.new(uuid_str).hash
  end

  test "#to_s" do
    uuid_str = SecureRandom.uuid

    assert_equal uuid_str.to_s, MyUUID.new(uuid_str).to_s
  end
end
