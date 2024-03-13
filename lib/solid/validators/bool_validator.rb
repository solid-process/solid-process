# frozen_string_literal: true

class BoolValidator < ActiveModel::EachValidator
  def validate_each(obj, attribute, value)
    return if value == true || value == false

    obj.errors.add attribute, (options[:message] || "is not a boolean")
  end
end
