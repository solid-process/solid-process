# frozen_string_literal: true

require "solid/validators"

class RespondToValidator < ActiveModel::EachValidator
  def validate_each(model, attribute, value)
    with_option = Array.wrap(options[:with] || options[:in])

    return if with_option.all? { value.respond_to?(_1) }

    message = "does not respond to #{with_option.map(&:inspect).join(" & ")}"

    Solid::Validators.add_error(model, attribute, message, options)
  end
end
