# frozen_string_literal: true

require "solid/validators"

class IsValidator < ActiveModel::EachValidator
  def validate_each(model, attribute, value)
    with_option = Array.wrap(options[:with] || options[:in])

    return if with_option.all? do |predicate|
      raise ArgumentError, "expected a predicate method, got #{predicate.inspect}" unless predicate.end_with?("?")

      value.try(predicate)
    end

    message = "does not satisfy the predicate#{"s" if with_option.size > 1}: #{with_option.join(" & ")}"

    Solid::Validators.add_error(model, attribute, message, options)
  end
end
