# frozen_string_literal: true

require "test_helper"

class Solid::Process::CallbacksAroundCallTest < ActiveSupport::TestCase
  class PersonCreation < Solid::Process
    input do
      attribute :name, :string
      attribute :email, :string

      before_validation do |input|
        input.name = input.name.strip
        input.email = input.email.strip.downcase
      end

      validates :name, presence: true
      validates :email, presence: true, format: {with: TestUtils::EMAIL_REGEX}
    end

    attr_reader :callback_data

    def initialize(...)
      super(...)

      @callback_data = {before: {}, after: {}}
    end

    around_call do |process, block|
      raise unless equal?(process)

      @callback_data[:before][:name] = input.name
      @callback_data[:before][:email] = input.email

      block.call

      @callback_data[:after][:name] = input.name
      @callback_data[:after][:email] = input.email
    end

    def call(attributes)
      person = attributes.fetch_values(:name, :email)

      Success(:person_created, person: person)
    end
  end

  test "around call" do
    person_creation = PersonCreation.new

    person_creation.call(name: " John Doe\n", email: " JOHN.doE@email.com ")

    assert_equal(" John Doe\n", person_creation.callback_data[:before][:name])
    assert_equal(" JOHN.doE@email.com ", person_creation.callback_data[:before][:email])

    assert_equal("John Doe", person_creation.callback_data[:after][:name])
    assert_equal("john.doe@email.com", person_creation.callback_data[:after][:email])

    assert_equal("John Doe", person_creation.input.name)
    assert_equal("john.doe@email.com", person_creation.input.email)
  end
end
