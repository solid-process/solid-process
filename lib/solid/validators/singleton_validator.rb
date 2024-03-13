# frozen_string_literal: true

class SingletonValidator < ActiveModel::EachValidator
  def validate_each(obj, attribute, value)
    with_option = Array.wrap(options[:with] || options[:in])

    unless value.is_a?(Module)
      return obj.errors.add(attribute, options[:message] || "is not a class or module")
    end

    is_valid = with_option.any? do |type|
      type.is_a?(Module) or raise ArgumentError, "#{type.inspect} is not a class or module"

      value == type || (value < type || value.is_a?(type))
    end

    expectation = with_option.map(&:name).join(" | ")

    is_valid or obj.errors.add(attribute, (options[:message] || "is not #{expectation}"))
  end
end
