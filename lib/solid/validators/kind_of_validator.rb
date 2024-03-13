# frozen_string_literal: true

class KindOfValidator < ActiveModel::EachValidator
  def validate_each(obj, attribute, value)
    with_option = Array.wrap(options[:with] || options[:in])

    return if with_option.any? { |type| value.is_a?(type) }

    expectation = with_option.map(&:name).join(" | ")

    obj.errors.add(attribute, (options[:message] || "is not a #{expectation}"))
  end
end
