# frozen_string_literal: true

require "test_helper"

class Solid::Process::InputAssignmentTest < ActiveSupport::TestCase
  Person = Struct.new(:uuid, :name, :email)

  class PersonInput < Solid::Input
    attribute :uuid, :string, default: -> { SecureRandom.uuid }
    attribute :name, :string
    attribute :email, :string

    before_validation do |input|
      input.name = input.name.strip
      input.email = input.email.strip.downcase
    end

    validates :name, presence: true
    validates :uuid, presence: true, format: {with: TestUtils::UUID_REGEX}
    validates :email, presence: true, format: {with: TestUtils::EMAIL_REGEX}
  end

  class PersonCreation < Solid::Process
    self.input = PersonInput

    def call(attributes)
      person = Person.new(*attributes.fetch_values(:uuid, :name, :email))

      Success(:person_created, person: person)
    end
  end

  test "the process input" do
    assert_same PersonCreation::Input, PersonCreation.input

    input = PersonCreation::Input.new(
      name: "  John Doe\t",
      email: " joHn.dOE@example.COM "
    )

    input.valid?

    assert_match TestUtils::UUID_REGEX, input.uuid
    assert_equal "John Doe", input.name
    assert_equal "john.doe@example.com", input.email
  end

  test "the process calling" do
    uuid = SecureRandom.uuid

    result = PersonCreation.call(
      uuid: uuid,
      name: "  John Doe\t",
      email: " joHn.dOE@example.COM "
    )

    assert result.success?(:person_created)

    person = result.value.fetch(:person)

    assert_match uuid, person.uuid
    assert_equal "John Doe", person.name
    assert_equal "john.doe@example.com", person.email
  end

  test "the assignment of an invalid class" do
    err = assert_raises ArgumentError do
      Class.new(Solid::Process) do
        self.input = String
      end
    end

    assert_equal "String must be a class that includes Solid::Model", err.message
  end

  test "the assignment after the class definition" do
    err = assert_raises Solid::Process::Error do
      PersonCreation.input = String
    end

    assert_equal "#{PersonCreation::Input} class already defined", err.message
  end
end
