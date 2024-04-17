# frozen_string_literal: true

require "test_helper"
require "solid/validators/email_validator"

class Solid::EmailValidatorTest < ActiveSupport::TestCase
  class Input < Solid::Input
    attribute :email1
    attribute :email2
    attribute :email3

    validates :email1, email: true
    validates :email2, email: true, allow_nil: true
    validates :email3, email: true, allow_blank: true
  end

  test "email validator" do
    input = Input.new

    input.email1 = "foo@foo.com"
    input.email2 = "bar@bar.com"
    input.email3 = "biz@biz.com"

    assert_predicate input, :valid?

    input.email1 = "foo"
    input.email2 = "bar"
    input.email3 = "biz"

    refute_predicate input, :valid?

    assert_equal ["is invalid"], input.errors[:email1]
    assert_equal ["is invalid"], input.errors[:email2]
    assert_equal ["is invalid"], input.errors[:email3]

    input.email1 = nil
    input.email2 = nil
    input.email3 = nil

    refute_predicate input, :valid?

    assert_equal ["can't be blank"], input.errors[:email1]
    assert_empty input.errors[:email2]
    assert_empty input.errors[:email3]

    input.email1 = ""
    input.email2 = ""
    input.email3 = ""

    refute_predicate input, :valid?

    assert_equal ["can't be blank"], input.errors[:email1]
    assert_equal ["can't be blank"], input.errors[:email2]
    assert_empty input.errors[:email3]

    input.email1 = "foo@foo.com"
    input.email2 = nil

    assert_predicate input, :valid?
  end
end
