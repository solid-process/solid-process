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
    require "solid/process/caller"
    require "solid/process/class_methods"
    require "solid/process/active_record"

    extend ClassMethods

    include ::BCDD::Result::Context.mixin(config: {addon: {continue: true}})

    def self.inherited(subclass)
      subclass.prepend(Caller)
      subclass.include(Result::Callbacks)
    end

    def self.call(arg = nil)
      new.call(arg)
    end

    attr_accessor :input, :output, :dependencies

    private :input=, :output=, :dependencies=

    def initialize(arg = nil)
      self.dependencies = self.class.dependencies&.then { arg.instance_of?(_1) ? arg : _1.new(arg) }
    end

    def input?
      !input.nil?
    end

    def output?(type = nil)
      type.nil? ? !output.nil? : !!output&.is?(type)
    end

    def dependencies?
      !dependencies.nil?
    end

    def call(_arg = nil)
      raise Error, "#{self.class}#call must be implemented."
    end

    def inspect
      "#<#{self.class.name} dependencies=#{dependencies.inspect} input=#{input.inspect} output=#{output.inspect}>"
    end

    def method_missing(name, *args, &block)
      name.end_with?("?") ? output&.is?(name.to_s.chomp("?")) : super
    end

    def respond_to_missing?(name, include_private = false)
      name.end_with?("?") || super
    end

    alias_method :deps, :dependencies
    alias_method :deps?, :dependencies?
    alias_method :result, :output
    alias_method :result?, :output?
  end
end
