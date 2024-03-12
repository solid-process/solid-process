# frozen_string_literal: true

require "test_helper"

class Solid::Process::DependenciesAssignmentTest < ActiveSupport::TestCase
  class PersonDependencies < Solid::Input
    attribute :struct, default: Struct.new(:uuid, :name)
  end

  class PersonCreation < Solid::Process
    self.dependencies = PersonDependencies

    input do
      attribute :uuid, :string, default: -> { SecureRandom.uuid }
      attribute :name, :string
    end

    def call(attributes)
      person = dependencies.struct.new(*attributes.fetch_values(:uuid, :name))

      Success(:person_created, person: person)
    end
  end

  test "the process dependencies" do
    assert_same PersonCreation::Dependencies, PersonCreation.dependencies

    assert_operator PersonCreation::Dependencies, :<, Solid::Input

    struct = PersonCreation.dependencies.new.struct.new("uuid", "name")

    assert_equal "uuid", struct.uuid
    assert_equal "name", struct.name
  end

  test "the process calling" do
    uuid = SecureRandom.uuid

    result = PersonCreation.call(
      uuid: uuid,
      name: "John Doe"
    )

    assert result.success?(:person_created)

    person = result.value.fetch(:person)

    assert_match uuid, person.uuid
    assert_equal "John Doe", person.name
  end

  test "the assignment of an invalid class" do
    err = assert_raises ArgumentError do
      Class.new(Solid::Process) do
        self.dependencies = String
      end
    end

    assert_equal "String must be a class that includes Solid::Model", err.message
  end

  test "the assignment after the class definition" do
    err = assert_raises Solid::Process::Error do
      PersonCreation.dependencies = String
    end

    assert_equal "#{PersonCreation::Dependencies} class already defined", err.message
  end
end
