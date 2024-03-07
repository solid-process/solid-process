# frozen_string_literal: true

module Solid
  class Process
    private

    if defined?(::ActiveRecord)
      def rollback_on_failure(model: ::ActiveRecord::Base)
        result = nil

        model.transaction do
          result = yield

          raise ::ActiveRecord::Rollback if result.failure?
        end

        result
      end
    end
  end
end
