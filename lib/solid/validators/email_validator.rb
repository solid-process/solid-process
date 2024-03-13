# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  def validate_each(obj, attribute, value)
    return if value.is_a?(String) && URI::MailTo::EMAIL_REGEXP.match?(value)

    obj.errors.add attribute, (options[:message] || "is not an email")
  end
end
