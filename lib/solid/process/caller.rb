# frozen_string_literal: true

class Solid::Process
  module Caller
    def call(arg = {})
      if output?
        raise Error, "#{self.class}#call already called. " \
                     "Use #{self.class}#output to access the result or create a new instance to call again."
      end

      self.input = self.class.input.new(arg)

      ::BCDD::Result.transitions(name: self.class.name) do
        self.output =
          if input.invalid?
            Failure(:invalid_input, input: input)
          else
            super(input.attributes.deep_symbolize_keys)
          end
      end
    end
  end
end
