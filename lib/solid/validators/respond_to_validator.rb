# frozen_string_literal: true

class RespondToValidator < ActiveModel::EachValidator
  def validate_each(obj, attribute, value)
    with_option = Array.wrap(options[:with] || options[:in])

    return if with_option.all? { value.respond_to?(_1) }

    expectation = with_option.map(&:inspect).join(" & ")

    obj.errors.add(attribute, (options[:message] || "does not respond to #{expectation}"))
  end
end
