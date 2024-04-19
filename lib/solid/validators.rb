# frozen_string_literal: true

module Solid
  module Validators
    def self.add_error(model, attribute, message, options)
      if ActiveModel.const_defined?(:Error)
        model.errors.add(attribute, **options.merge(message: message))
      else
        model.errors.add(attribute, options.fetch(:message, message))
      end
    end
  end
end
