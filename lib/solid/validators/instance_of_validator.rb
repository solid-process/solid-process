# frozen_string_literal: true

require "solid/validators"

class InstanceOfValidator < ActiveModel::EachValidator
  def validate_each(model, attribute, value)
    with_option = Array.wrap(options[:with] || options[:in])

    return if with_option.any? { |type| value.instance_of?(type) }

    message = "is not an instance of #{with_option.map(&:name).join(" | ")}"

    Solid::Validators.add_error(model, attribute, message, options)
  end
end
