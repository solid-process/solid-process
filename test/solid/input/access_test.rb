# frozen_string_literal: true

require "test_helper"

class Solid::InputAccessTest < ActiveSupport::TestCase
  class PersonInput < Solid::Input
    attribute :uuid, :string
    attribute :name, :string
    attribute :email, :string
  end

  test "#slice" do
    input = PersonInput.new(
      uuid: SecureRandom.uuid,
      name: "John Doe",
      email: "john.doe@example.com"
    )

    slice1 = input.slice(:uuid, :name, :email)
    slice2 = input.slice(:uuid, :email)
    slice3 = input.slice(:name)

    assert_equal(
      {"uuid" => input.uuid, "name" => input.name, "email" => input.email},
      slice1
    )
    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, slice1)

    assert_equal({"uuid" => input.uuid, "email" => input.email}, slice2)
    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, slice2)

    assert_equal({"name" => input.name}, slice3)
    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, slice3)

    assert_empty(input.slice)
    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, input.slice)
  end

  test "#values_at" do
    input = PersonInput.new(
      uuid: SecureRandom.uuid,
      name: "John Doe",
      email: "john.doe@example.com"
    )

    slice1 = input.values_at(:uuid, :name, :email)
    slice2 = input.values_at(:uuid, :email)
    slice3 = input.values_at(:name)

    assert_equal([input.uuid, input.name, input.email], slice1)
    assert_equal([input.uuid, input.email], slice2)
    assert_equal([input.name], slice3)

    assert_empty(input.values_at)
    assert_instance_of(Array, input.values_at)
  end
end
