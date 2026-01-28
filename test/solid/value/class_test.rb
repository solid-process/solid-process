# frozen_string_literal: true

require "test_helper"

class Solid::ValueClassTest < ActiveSupport::TestCase
  class ValueWithDefaults
    include Solid::Value

    attribute :string, default: -> { SecureRandom.uuid }
  end

  test "value with default values" do
    uuid_str = SecureRandom.uuid

    uuid1 = ValueWithDefaults.new
    uuid2 = ValueWithDefaults.new(uuid_str)

    assert_match TestUtils::UUID_REGEX, uuid1.value
    assert_equal uuid_str, uuid2.value
  end

  class ValueWithNormalization
    include Solid::Value

    attribute :string

    before_validation do |model|
      self.value = model.value.strip.downcase
    end
  end

  test "value with normalization (before_validation)" do
    uuid_str = SecureRandom.uuid

    uuid = ValueWithNormalization.new(" #{uuid_str}  ")
    uuid.valid?

    assert_equal uuid_str, uuid.value
  end

  class ValueWithValidation
    include Solid::Value

    attribute :string

    validates presence: true, format: {with: TestUtils::UUID_REGEX}
  end

  test "value with validation" do
    uuid1 = ValueWithValidation.new
    uuid2 = ValueWithValidation.new(" ")
    uuid3 = ValueWithValidation.new("invalid")
    uuid4 = ValueWithValidation.new(SecureRandom.uuid)

    assert_predicate uuid1, :invalid?
    assert_predicate uuid2, :invalid?
    assert_predicate uuid3, :invalid?

    assert_predicate uuid4, :valid?
  end

  if ActiveModel::Attributes.const_defined?(:Normalization, false)
    class ValueWithNormalizes
      include Solid::Value

      attribute :string

      normalizes with: -> { _1.strip.downcase }
    end

    test "value with normalizes" do
      uuid_str = SecureRandom.uuid

      uuid = ValueWithNormalizes.new(" #{uuid_str.upcase}  ")

      assert_equal uuid_str, uuid.value
    end
  end
end
