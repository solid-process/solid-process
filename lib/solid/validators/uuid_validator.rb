# frozen_string_literal: true

class UuidValidator < ActiveModel::EachValidator
  PATTERN = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
  CASE_SENSITIVE = /\A#{PATTERN}\z/.freeze
  CASE_INSENSITIVE = /\A#{PATTERN}\z/i.freeze

  def validate_each(obj, attribute, value)
    case_sensitive = options.fetch(:case_sensitive, true)

    regexp = case_sensitive ? CASE_SENSITIVE : CASE_INSENSITIVE

    return if value.is_a?(String) && value.match?(regexp)

    message = options[:message] || "is not a valid UUID (case #{case_sensitive ? "sensitive" : "insensitive"})"

    obj.errors.add(attribute, message)
  end

  private_constant :PATTERN
end
