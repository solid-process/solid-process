# frozen_string_literal: true

require "test_helper"

class Solid::ModelAccessTest < ActiveSupport::TestCase
  class Person
    include Solid::Model

    attribute :uuid, :string
    attribute :name, :string
    attribute :email, :string
  end

  test "#[]" do
    person = Person.new(
      uuid: SecureRandom.uuid,
      name: "John Doe",
      email: "john.doe@example.com"
    )

    assert_equal(person.uuid, person[:uuid])
    assert_equal(person.name, person[:name])
    assert_equal(person.email, person[:email])

    assert_equal(person.uuid, person["uuid"])
    assert_equal(person.name, person["name"])
    assert_equal(person.email, person["email"])
  end

  test "#slice" do
    person = Person.new(
      uuid: SecureRandom.uuid,
      name: "John Doe",
      email: "john.doe@example.com"
    )

    slice1 = person.slice(:uuid, :name, :email)
    slice2 = person.slice(:uuid, :email)
    slice3 = person.slice(:name)

    assert_equal(
      {"uuid" => person.uuid, "name" => person.name, "email" => person.email},
      slice1
    )
    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, slice1)

    assert_equal({"uuid" => person.uuid, "email" => person.email}, slice2)
    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, slice2)

    assert_equal({"name" => person.name}, slice3)
    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, slice3)

    assert_empty(person.slice)
    assert_instance_of(ActiveSupport::HashWithIndifferentAccess, person.slice)
  end

  test "#values_at" do
    person = Person.new(
      uuid: SecureRandom.uuid,
      name: "John Doe",
      email: "john.doe@example.com"
    )

    values1 = person.values_at(:uuid, :name, :email)
    values2 = person.values_at(:uuid, :email)
    values3 = person.values_at(:name)

    assert_equal([person.uuid, person.name, person.email], values1)
    assert_equal([person.uuid, person.email], values2)
    assert_equal([person.name], values3)

    assert_empty(person.values_at)
    assert_instance_of(Array, person.values_at)
  end
end
