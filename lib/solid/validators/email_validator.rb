# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  def validate_each(model, attribute, value)
    return model.errors.add(attribute, :blank, **options) if value.blank?

    return if value.is_a?(String) && URI::MailTo::EMAIL_REGEXP.match?(value)

    model.errors.add(attribute, :invalid, **options)
  end
end
