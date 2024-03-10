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

    attr_accessor :input, :output

    private :input=, :output=

    def input?
      !input.nil?
    end

    def output?
      !output.nil?
    end

    def call(attributes)
      raise Error, "#{self.class}#call must be implemented."
    end
  end
end
