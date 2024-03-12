# frozen_string_literal: true

require "test_helper"

class Solid::InputClassTest < ActiveSupport::TestCase
  class InputWithDefaults < Solid::Input
    attribute :uuid, :string, default: -> { SecureRandom.uuid }
  end

  test "input with default values" do
    uuid = SecureRandom.uuid

    input1 = InputWithDefaults.new
    input2 = InputWithDefaults.new(uuid: uuid)

    assert_match TestUtils::UUID_REGEX, input1.uuid
    assert_equal uuid, input2.uuid
  end

  class InputWithNormalization < Solid::Input
    attribute :uuid, :string

    before_validation do |input|
      input.uuid = input.uuid.strip.downcase
    end
  end

  test "input with normalization (before_validation)" do
    uuid = SecureRandom.uuid

    input = InputWithNormalization.new(uuid: " #{uuid.upcase}  ")
    input.valid?

    assert_equal uuid, input.uuid
  end

  class InputWithValidation < Solid::Input
    attribute :uuid, :string

    validates :uuid, presence: true, format: {with: TestUtils::UUID_REGEX}
  end

  test "input with validation" do
    input1 = InputWithValidation.new
    input2 = InputWithValidation.new(uuid: " ")
    input3 = InputWithValidation.new(uuid: "invalid")
    input4 = InputWithValidation.new(uuid: SecureRandom.uuid)

    assert_predicate input1, :invalid?
    assert_predicate input2, :invalid?
    assert_predicate input3, :invalid?

    assert_predicate input4, :valid?
  end

  test "input ancestors" do
    input_class = [InputWithDefaults, InputWithNormalization, InputWithValidation].sample

    ancestors = input_class.ancestors

    assert_includes ancestors, Solid::Input

    if ActiveModel.const_defined?(:Api, false)
      assert_includes ancestors, ActiveModel::Api
    else
      assert_includes ancestors, ActiveModel::Model
    end

    if ActiveModel.const_defined?(:Access, false)
      assert_includes ancestors, ActiveModel::Access
    else
      assert_includes ancestors, Solid::Model::Access
    end

    assert_includes ancestors, ActiveModel::Attributes
    assert_includes ancestors, ActiveModel::Dirty
    assert_includes ancestors, ActiveModel::Validations::Callbacks
  end
end
