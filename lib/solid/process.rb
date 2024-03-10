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
    require "solid/process/class_methods"
    require "solid/process/active_record"

    extend ClassMethods

    include ::BCDD::Result::Context.mixin(config: {addon: {continue: true}})

    attr_accessor :input, :output, :dependencies

    private :input=, :output=, :dependencies=

    def initialize(arg = nil)
      self.dependencies = self.class.dependencies&.then { arg.instance_of?(_1) ? arg : _1.new(arg) }
    end

    def input?
      !input.nil?
    end

    def output?
      !output.nil?
    end

    def dependencies?
      !dependencies.nil?
    end

    def call(_arg = nil)
      raise Error, "#{self.class}#call must be implemented."
    end

    alias_method :deps, :dependencies
    alias_method :deps?, :dependencies?
  end
end
