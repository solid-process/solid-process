# frozen_string_literal: true

require "test_helper"

class Solid::Process::ResultCallbacksTest < ActiveSupport::TestCase
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

    attr_reader :callback_numbers

    def initialize(...)
      super(...)

      @callback_numbers = []
    end

    after_success do |process|
      callback_numbers << 1
    end

    after_success if: -> { output.is?(:person_created) } do
      callback_numbers << 2
    end

    after_success if: :person_created? do
      callback_numbers << 3
    end

    after_success if: -> { _1.output.is?(:user_created) } do
      callback_numbers << 4
    end

    after_failure do |process|
      callback_numbers << -1
    end

    after_failure if: -> { output.is?(:invalid_input) } do
      callback_numbers << -2
    end

    after_failure if: :invalid_input? do
      callback_numbers << -3
    end

    after_failure if: -> { _1.output.is?(:invalid_person) } do
      callback_numbers << -4
    end

    def call(attributes)
      person = attributes.fetch_values(:uuid, :name, :email)

      Success(:person_created, person: person)
    end
  end

  test "after success" do
    person_creation = PersonCreation.new

    result = person_creation.call(
      uuid: SecureRandom.uuid,
      name: "John Doe",
      email: "john.doe@email.com"
    )

    assert result.is?(:person_created)

    assert_equal [1, 2, 3], person_creation.callback_numbers
  end

  test "after failure" do
    person_creation = PersonCreation.new

    result = person_creation.call(
      uuid: SecureRandom.uuid,
      name: "",
      email: "invalid-email"
    )

    assert result.is?(:invalid_input)

    assert_equal [-1, -2, -3], person_creation.callback_numbers
  end
end
