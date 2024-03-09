# frozen_string_literal: true

require "active_support/all"
require "active_model"
require "bcdd/result"

module Solid
  require "solid/input"
  require "solid/result"

  class Process
    require "solid/process/version"
    require "solid/process/error"
    require "solid/process/active_record"

    class << self
      def input=(klass)
        const_defined?(:Input, false) and raise Error, "#{const_get(:Input, false)} class already defined"

        unless klass.is_a?(::Class) && klass < ::Solid::Input
          raise ArgumentError, "#{klass.inspect} must be a #{::Solid::Input} subclass"
        end

        const_set(:Input, klass)
      end

      def input(&block)
        return const_get(:Input, false) if const_defined?(:Input, false)

        block.nil? and raise Error, "#{self}::Input is undefined. Use #{self}.input { ... } to define it."

        klass = ::Class.new(Input)
        klass.class_eval(&block)

        self.input = klass
      end

      def inherited(subclass)
        subclass.include ::BCDD::Result::Context.mixin(config: {addon: {continue: true}})
      end

      def call(arg = {})
        new(input.new(arg)).call!
      end
    end

    private_class_method :new

    attr_reader :input

    def initialize(input)
      @input = input
    end

    def call!
      ::BCDD::Result.transitions(name: self.class.name) do
        if input.invalid?
          Failure(:invalid_input, input: input)
        else
          call(input.attributes.deep_symbolize_keys)
        end
      end
    end

    def call(attributes)
      raise Error, "must be implemented in a subclass"
    end
  end
end
