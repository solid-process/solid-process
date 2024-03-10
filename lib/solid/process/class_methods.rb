# frozen_string_literal: true

class Solid::Process
  require_relative "caller"

  module ClassMethods
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

      klass = ::Class.new(::Solid::Input)
      klass.class_eval(&block)

      self.input = klass
    end

    def inherited(subclass)
      subclass.prepend(Caller)
    end

    def call(arg = {})
      new.call(arg)
    end
  end
end
