# frozen_string_literal: true

require "test_helper"

class Solid::ModelClassTest < ActiveSupport::TestCase
  class ModelWithDefaults
    include Solid::Model

    attribute :uuid, :string, default: -> { SecureRandom.uuid }
  end

  test "model with default values" do
    uuid = SecureRandom.uuid

    model1 = ModelWithDefaults.new
    model2 = ModelWithDefaults.new(uuid: uuid)

    assert_match TestUtils::UUID_REGEX, model1.uuid
    assert_equal uuid, model2.uuid
  end

  class ModelWithNormalization
    include Solid::Model

    attribute :uuid, :string

    before_validation do |model|
      model.uuid = model.uuid.strip.downcase
    end
  end

  test "model with normalization (before_validation)" do
    uuid = SecureRandom.uuid

    model = ModelWithNormalization.new(uuid: " #{uuid.upcase}  ")
    model.valid?

    assert_equal uuid, model.uuid
  end

  class ModelWithValidation
    include Solid::Model

    attribute :uuid, :string

    validates :uuid, presence: true, format: {with: TestUtils::UUID_REGEX}
  end

  test "model with validation" do
    model1 = ModelWithValidation.new
    model2 = ModelWithValidation.new(uuid: " ")
    model3 = ModelWithValidation.new(uuid: "invalid")
    model4 = ModelWithValidation.new(uuid: SecureRandom.uuid)

    assert_predicate model1, :invalid?
    assert_predicate model2, :invalid?
    assert_predicate model3, :invalid?

    assert_predicate model4, :valid?
  end

  test "model ancestors" do
    model_class = [ModelWithDefaults, ModelWithNormalization, ModelWithValidation].sample

    ancestors = model_class.ancestors

    assert_includes ancestors, Solid::Model

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
