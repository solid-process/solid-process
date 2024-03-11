# frozen_string_literal: true

require "test_helper"

class Solid::Process::InputInspectTest < ActiveSupport::TestCase
  class PersonInput < Solid::Input
    attribute :uuid, :string
    attribute :name, :string
    attribute :email, :string
  end

  test "#inspect" do
    uuid = SecureRandom.uuid
    name = "John"
    email = "john@example.com"

    input = PersonInput.new(uuid: uuid, name: name, email: email)

    assert_match(/#<.+PersonInput uuid=#{uuid.inspect} name=#{name.inspect} email=#{email.inspect}>/, input.inspect)
  end
end
