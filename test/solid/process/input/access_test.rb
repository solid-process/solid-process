# frozen_string_literal: true

require "test_helper"

class Solid::Process::InputAccessTest < ActiveSupport::TestCase
  PersonStruct = Struct.new(:uuid, :name, :email, keyword_init: true)
  PersonStruct.include(Solid::Input::Access)

  class PersonInput < Solid::Input
    attribute :uuid, :string
    attribute :name, :string
    attribute :email, :string
  end

  test "#slice" do
    uuid = SecureRandom.uuid
    name = "John"
    email = "john@example.com"

    input = PersonInput.new(uuid: uuid, name: name, email: email)
    struct = PersonStruct.new(uuid: uuid, name: name, email: email)

    assert_equal({"uuid" => uuid}, input.slice(:uuid))
    assert_equal({"uuid" => uuid}, struct.slice(:uuid))

    assert_equal({"uuid" => uuid, "name" => name}, input.slice(:uuid, :name))
    assert_equal({"uuid" => uuid, "name" => name}, struct.slice(:uuid, :name))

    assert_equal({"uuid" => uuid, "name" => name, "email" => email}, input.slice(:uuid, :name, :email))
    assert_equal({"uuid" => uuid, "name" => name, "email" => email}, struct.slice(:uuid, :name, :email))

    assert_equal({}, input.slice)
    assert_equal({}, struct.slice)
  end

  test "#values_at" do
    uuid = SecureRandom.uuid
    name = "John"
    email = "john@example.com"

    input = PersonInput.new(uuid: uuid, name: name, email: email)
    struct = PersonStruct.new(uuid: uuid, name: name, email: email)

    assert_equal [uuid], input.values_at(:uuid)
    assert_equal [uuid], struct.values_at(:uuid)

    assert_equal [uuid, name], input.values_at(:uuid, :name)
    assert_equal [uuid, name], struct.values_at(:uuid, :name)

    assert_equal [uuid, name, email], input.values_at(:uuid, :name, :email)
    assert_equal [uuid, name, email], struct.values_at(:uuid, :name, :email)

    assert_equal [], input.values_at
    assert_equal [], struct.values_at
  end
end
