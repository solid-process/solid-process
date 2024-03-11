# frozen_string_literal: true

class Solid::Process
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

    def dependencies=(klass)
      const_defined?(:Dependencies, false) and raise Error, "#{const_get(:Dependencies, false)} class already defined"

      unless klass.is_a?(::Class) && klass < ::Solid::Input
        raise ArgumentError, "#{klass.inspect} must be a #{::Solid::Input} subclass"
      end

      const_set(:Dependencies, klass)
    end

    def dependencies(&block)
      return const_get(:Dependencies, false) if const_defined?(:Dependencies, false)

      return if block.nil?

      klass = ::Class.new(::Solid::Input)
      klass.class_eval(&block)

      self.dependencies = klass
    end
  end
end
