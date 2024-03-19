# frozen_string_literal: true

class Solid::Process
  class Config
    SolidModel = ->(klass) do
      return klass if klass.is_a?(::Class) && klass < ::Solid::Model

      raise ArgumentError, "#{klass.inspect} must be a class that includes #{::Solid::Model}"
    end

    attr_reader :input_class, :dependencies_class

    def initialize
      self.input_class = ::Solid::Input
      self.dependencies_class = ::Solid::Input
    end

    def input_class=(klass)
      @input_class = SolidModel[klass]
    end

    def dependencies_class=(klass)
      @dependencies_class = SolidModel[klass]
    end

    alias_method :deps_class, :dependencies_class
    alias_method :deps_class=, :dependencies_class=

    class << self
      attr_reader :instance
    end

    @instance = new
  end
end
