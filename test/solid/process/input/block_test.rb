# frozen_string_literal: true

require "test_helper"

class Solid::Process::InputBlockTest < ActiveSupport::TestCase
  Person = Struct.new(:uuid, :name, :email)

  class PersonCreation < Solid::Process
    input do
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
end
