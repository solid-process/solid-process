# frozen_string_literal: true

require "test_helper"
require "solid/validators/uuid_validator"

class Solid::UuidValidatorTest < ActiveSupport::TestCase
  class InputCaseSensitive < Solid::Input
    attribute :uuid1
    attribute :uuid2
    attribute :uuid3

    validates :uuid1, uuid: true
    validates :uuid2, uuid: true, allow_nil: true
    validates :uuid3, uuid: true, allow_blank: true
  end

  class InputCaseInsensitive < Solid::Input
    attribute :uuid1
    attribute :uuid2
    attribute :uuid3

    validates :uuid1, uuid: {case_sensitive: false}
    validates :uuid2, uuid: {case_sensitive: false}, allow_nil: true
    validates :uuid3, uuid: {case_sensitive: false}, allow_blank: true
  end

  test "uuid validator (case sensitive)" do
    input = InputCaseSensitive.new

    input.uuid1 = SecureRandom.uuid
    input.uuid2 = SecureRandom.uuid
    input.uuid3 = SecureRandom.uuid

    assert_predicate input, :valid?

    input.uuid1 = SecureRandom.uuid.upcase
    input.uuid2 = SecureRandom.uuid.upcase
    input.uuid3 = SecureRandom.uuid.upcase

    refute_predicate input, :valid?

    assert_equal ["is not a valid UUID (case sensitive)"], input.errors[:uuid1]
    assert_equal ["is not a valid UUID (case sensitive)"], input.errors[:uuid2]
    assert_equal ["is not a valid UUID (case sensitive)"], input.errors[:uuid3]

    input.uuid1 = nil
    input.uuid2 = nil
    input.uuid3 = nil

    refute_predicate input, :valid?

    assert_equal ["is not a valid UUID (case sensitive)"], input.errors[:uuid1]
    assert_empty input.errors[:uuid2]
    assert_empty input.errors[:uuid3]

    input.uuid1 = ""
    input.uuid2 = ""
    input.uuid3 = ""

    refute_predicate input, :valid?

    assert_equal ["is not a valid UUID (case sensitive)"], input.errors[:uuid1]
    assert_equal ["is not a valid UUID (case sensitive)"], input.errors[:uuid2]
    assert_empty input.errors[:uuid3]

    input.uuid1 = SecureRandom.uuid
    input.uuid2 = nil

    assert_predicate input, :valid?
  end

  test "uuid validator (case insensitive)" do
    input = InputCaseInsensitive.new

    input.uuid1 = SecureRandom.uuid
    input.uuid2 = SecureRandom.uuid
    input.uuid3 = SecureRandom.uuid

    assert_predicate input, :valid?

    input.uuid1 = SecureRandom.uuid.upcase
    input.uuid2 = SecureRandom.uuid.upcase
    input.uuid3 = SecureRandom.uuid.upcase

    assert_predicate input, :valid?

    input.uuid1 = "0374c4f"
    input.uuid2 = "0374c4f"
    input.uuid3 = "0374c4f"

    refute_predicate input, :valid?

    assert_equal ["is not a valid UUID (case insensitive)"], input.errors[:uuid1]
    assert_equal ["is not a valid UUID (case insensitive)"], input.errors[:uuid2]
    assert_equal ["is not a valid UUID (case insensitive)"], input.errors[:uuid3]

    input.uuid1 = nil
    input.uuid2 = nil
    input.uuid3 = nil

    refute_predicate input, :valid?

    assert_equal ["is not a valid UUID (case insensitive)"], input.errors[:uuid1]
    assert_empty input.errors[:uuid2]
    assert_empty input.errors[:uuid3]

    input.uuid1 = ""
    input.uuid2 = ""
    input.uuid3 = ""

    refute_predicate input, :valid?

    assert_equal ["is not a valid UUID (case insensitive)"], input.errors[:uuid1]
    assert_equal ["is not a valid UUID (case insensitive)"], input.errors[:uuid2]
    assert_empty input.errors[:uuid3]

    input.uuid1 = SecureRandom.uuid
    input.uuid2 = nil

    assert_predicate input, :valid?
  end
end
