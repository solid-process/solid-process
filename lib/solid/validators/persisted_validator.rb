# frozen_string_literal: true

class PersistedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if (options[:allow_nil] && value.nil?) || value.try(:persisted?)

    record.errors.add(attribute, (options[:message] || "must be persisted"))
  end
end
