# frozen_string_literal: true

# rubocop:disable Lint/RescueException
class Solid::Process
  module Caller
    def call(arg = nil)
      output_already_set! if output?

      self.input = arg

      run_callbacks(:call) do
        ::Solid::Result.event_logs(name: self.class.name) do
          self.output =
            if dependencies&.invalid?
              Failure(:invalid_dependencies, dependencies: dependencies)
            elsif input.invalid?
              Failure(:invalid_input, input: input)
            else
              super(input.attributes.symbolize_keys)
            end
        rescue ::Exception => exception
          rescue_with_handler(exception) || raise

          output
        end
      end

      run_callbacks(:success) if output.success?
      run_callbacks(:failure) if output.failure?

      output
    end
  end
end
# rubocop:enable Lint/RescueException
