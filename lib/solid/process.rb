# frozen_string_literal: true

require "active_support/all"
require "active_model"
require "solid/result"

module Solid
  require "solid/input"

  def self.Success(...)
    ::Solid::Output::Success(...)
  end

  def self.Failure(...)
    ::Solid::Output::Failure(...)
  end

  class Process
    require "solid/process/version"
    require "solid/process/error"
    require "solid/process/config"
    require "solid/process/caller"
    require "solid/process/callbacks"
    require "solid/process/class_methods"
    require "solid/process/active_record"

    extend ClassMethods

    include Callbacks
    include ::ActiveSupport::Rescuable
    include ::Solid::Output.mixin(config: {addon: {continue: true}})

    def self.inherited(subclass)
      super

      subclass.prepend(Caller)
    end

    def self.call(arg = nil)
      new.call(arg)
    end

    def self.configuration(&block)
      yield config

      config.freeze
    end

    def self.config
      Config.instance
    end

    attr_reader :output, :input, :dependencies

    def initialize(arg = nil)
      self.dependencies = arg
    end

    def call(_arg = nil)
      raise Error, "#{self.class}#call must be implemented."
    end

    def with(dependencies)
      self.class.new(dependencies.with_indifferent_access.with_defaults(deps&.attributes))
    end

    def new(dependencies = {})
      with(dependencies)
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

    def success?(type = nil)
      !!output&.success?(type)
    end

    def failure?(type = nil)
      !!output&.failure?(type)
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

    private

    def dependencies=(arg)
      raise Error, "The `#{self.class}#dependencies` is already set." unless dependencies.nil?

      @dependencies = self.class.dependencies&.then { arg.instance_of?(_1) ? arg : _1.new(arg) }
    end

    def input=(arg)
      raise Error, "The `#{self.class}#input` is already set." unless input.nil?

      @input = self.class.input.then { arg.instance_of?(_1) ? arg : _1.new(arg) }
    end

    def output_already_set!
      raise Error, "The `#{self.class}#output` is already set. " \
                   "Use `.output` to access the result or create a new instance to call again."
    end

    def output=(result)
      output_already_set! unless output.nil?

      raise Error, "The result #{result.inspect} must be a Solid::Output." unless result.is_a?(::Solid::Output)

      @output = result
    end

    def Success!(...)
      return self.output = Success(...) if output.nil?

      raise Error, "`Success!()` cannot be called because the `#{self.class}#output` is already set."
    end

    def Failure!(...)
      return self.output = Failure(...) if output.nil?

      raise Error, "`Failure!()` cannot be called because the `#{self.class}#output` is already set."
    end
  end
end
