# frozen_string_literal: true

module Solid
  module Result
    require_relative "result/callbacks"

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

    def type?(arg)
      type == arg
    end

    def is?(arg)
      type?(arg.to_sym)
    end

    def method_missing(name, *args, &block)
      name.end_with?("?") ? is?(name.to_s.chomp("?")) : super
    end

    def respond_to_missing?(name, include_private = false)
      name.end_with?("?") || super
    end
  end

  Output = Result

  module Success
    include ::Solid::Result
  end

  module Failure
    include ::Solid::Result
  end

  ::BCDD::Result::Context::Success.prepend(Success)
  ::BCDD::Result::Context::Failure.prepend(Failure)

  def self.Success(...)
    ::BCDD::Result::Context::Success(...)
  end

  def self.Failure(...)
    ::BCDD::Result::Context::Failure(...)
  end
end
