# frozen_string_literal: true

require "solid/validators"

class KindOfValidator < ActiveModel::EachValidator
  def validate_each(model, attribute, value)
    with_option = Array.wrap(options[:with] || options[:in])

    return if with_option.any? { |type| value.is_a?(type) }

    message = "is not a #{with_option.map(&:name).join(" | ")}"

    Solid::Validators.add_error(model, attribute, message, options)
  end
end
