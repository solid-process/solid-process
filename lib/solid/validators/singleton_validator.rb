# frozen_string_literal: true

require "solid/validators"

class SingletonValidator < ActiveModel::EachValidator
  def validate_each(model, attribute, value)
    with_option = Array.wrap(options[:with] || options[:in])

    return model.errors.add(attribute, options[:message] || "is not a class or module") unless value.is_a?(Module)

    return if with_option.any? do |type|
      raise ArgumentError, "#{type.inspect} is not a class or module" unless type.is_a?(Module)

      value == type || (value < type || value.is_a?(type))
    end

    message = "is not #{with_option.map(&:name).join(" | ")}"

    Solid::Validators.add_error(model, attribute, message, options)
  end
end
