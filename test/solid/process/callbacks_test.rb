# frozen_string_literal: true

require "test_helper"

class Solid::Process::CallbacksTest < ActiveSupport::TestCase
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

      @callback_numbers = Hash.new { |hash, key| hash[key] = [] }
    end

    after_success do |process|
      callback_numbers[:after_success] << 1
    end

    after_success if: -> { output.is?(:person_created) } do
      callback_numbers[:after_success] << 2
    end

    after_success if: :person_created? do
      callback_numbers[:after_success] << 3
    end

    after_success if: :user_created? do
      callback_numbers[:after_success] << 4
    end

    after_output if: -> { output.is?(:person_created) } do
      callback_numbers[:after_output] << 5
    end

    after_output if: :person_created? do
      callback_numbers[:after_output] << 6
    end

    after_output if: :user_created? do
      callback_numbers[:after_output] << 7
    end

    after_result if: -> { result.is?(:person_created) } do
      callback_numbers[:after_result] << 8
    end

    after_result if: :person_created? do
      callback_numbers[:after_result] << 9
    end

    after_result if: :user_created? do
      callback_numbers[:after_result] << 10
    end

    after_failure do |process|
      callback_numbers[:after_failure] << -1
    end

    after_failure if: -> { output.is?(:invalid_input) } do
      callback_numbers[:after_failure] << -2
    end

    after_failure if: :invalid_input? do
      callback_numbers[:after_failure] << -3
    end

    after_failure if: :invalid_person? do
      callback_numbers[:after_failure] << -4
    end

    after_output if: -> { output.is?(:invalid_input) } do
      callback_numbers[:after_output] << -5
    end

    after_output if: :invalid_input? do
      callback_numbers[:after_output] << -6
    end

    after_output if: :invalid_person? do
      callback_numbers[:after_output] << -7
    end

    after_result if: -> { result.is?(:invalid_input) } do
      callback_numbers[:after_result] << -8
    end

    after_result if: :invalid_input? do
      callback_numbers[:after_result] << -9
    end

    after_result if: :invalid_person? do
      callback_numbers[:after_result] << -10
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

    assert_equal(
      {
        after_success: [1, 2, 3],
        after_output: [5, 6],
        after_result: [8, 9]
      },
      person_creation.callback_numbers
    )
  end

  test "after failure" do
    person_creation = PersonCreation.new

    result = person_creation.call(
      uuid: SecureRandom.uuid,
      name: "",
      email: "invalid-email"
    )

    assert result.is?(:invalid_input)

    assert_equal(
      {
        after_failure: [-1, -2, -3],
        after_output: [-5, -6],
        after_result: [-8, -9]
      },
      person_creation.callback_numbers
    )
  end
end
