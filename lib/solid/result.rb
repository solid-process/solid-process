# frozen_string_literal: true

module Solid
  module Result
    def deconstruct
      [type, value]
    end

    TYPE_AND_VALUE = %i[type value].freeze

    def deconstruct_keys(keys)
      return value if keys.none? { |key| TYPE_AND_VALUE.include?(key) }

      TYPE_AND_VALUE.each_with_object({}) do |key, hash|
        hash[key] = send(key) if keys.include?(key)
      end
    end
  end

  module Success
    include ::Solid::Result
  end

  module Failure
    include ::Solid::Result
  end

  ::BCDD::Result::Context::Success.prepend(Success)
  ::BCDD::Result::Context::Failure.prepend(Failure)
end
