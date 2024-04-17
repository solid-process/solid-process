# frozen_string_literal: true

require "solid/validators"

class IdValidator < ActiveModel::EachValidator
  OPTIONS = {only_integer: true, greater_than: 0}.freeze

  def validate_each(model, attribute, value)
    opts = OPTIONS.merge(options.except(*OPTIONS.keys))

    opts[:attributes] = attribute

    ::ActiveModel::Validations::NumericalityValidator.new(opts).validate_each(model, attribute, value)
  end

  private_constant :OPTIONS
end
