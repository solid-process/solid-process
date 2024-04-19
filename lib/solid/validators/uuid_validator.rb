# frozen_string_literal: true

class UuidValidator < ActiveModel::EachValidator
  PATTERN = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
  CASE_SENSITIVE = /\A#{PATTERN}\z/.freeze
  CASE_INSENSITIVE = /\A#{PATTERN}\z/i.freeze

  def validate_each(model, attribute, value)
    case_sensitive = options.fetch(:case_sensitive, true)

    return model.errors.add(attribute, :blank, **options) if value.blank?

    regexp = case_sensitive ? CASE_SENSITIVE : CASE_INSENSITIVE

    return if value.is_a?(String) && value.match?(regexp)

    model.errors.add(attribute, :invalid, **options)
  end

  private_constant :PATTERN
end
