# frozen_string_literal: true

class Solid::Process
  module ClassMethods
    def input=(klass)
      const_defined?(:Input, false) and raise Error, "#{const_get(:Input, false)} class already defined"

      const_set(:Input, Config::SolidModel[klass])
    end

    def input(&block)
      return const_get(:Input, false) if const_defined?(:Input, false)

      block.nil? and raise Error, "#{self}::Input is undefined. Use #{self}.input { ... } to define it."

      klass = ::Class.new(Config.instance.input_class)
      klass.class_eval(&block)

      self.input = klass
    end

    def dependencies=(klass)
      const_defined?(:Dependencies, false) and raise Error, "#{const_get(:Dependencies, false)} class already defined"

      const_set(:Dependencies, Config::SolidModel[klass])
    end

    def dependencies(&block)
      return const_get(:Dependencies, false) if const_defined?(:Dependencies, false)

      return if block.nil?

      klass = ::Class.new(Config.instance.dependencies_class)
      klass.class_eval(&block)

      self.dependencies = klass
    end

    alias_method :deps, :dependencies
    alias_method :deps=, :dependencies=
  end
end
