# frozen_string_literal: true

class Solid::Process
  module Caller
    def call(arg = nil)
      if output?
        raise Error, "#{self.class}#call already called. " \
                     "Use #{self.class}#output to access the result or create a new instance to call again."
      end

      self.input = self.class.input.then { arg.instance_of?(_1) ? arg : _1.new(arg) }

      ::BCDD::Result.transitions(name: self.class.name) do
        self.output =
          if dependencies&.invalid?
            Failure(:invalid_dependencies, dependencies: dependencies)
          elsif input.invalid?
            Failure(:invalid_input, input: input)
          else
            super(input.attributes.deep_symbolize_keys)
          end
      end

      run_callbacks(:success) if output.success?
      run_callbacks(:failure) if output.failure?
      run_callbacks(:output)

      output
    end
  end
end
