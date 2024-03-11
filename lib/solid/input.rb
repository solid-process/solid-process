# frozen_string_literal: true

class Solid::Input
  require_relative "input/access"

  module Mixins
    def self.active_model?(const_name)
      ::ActiveModel.const_defined?(const_name, false)
    end

    def self.api
      active_model?(:Api) ? ::ActiveModel::Api : ::ActiveModel::Model
    end

    def self.access
      active_model?(:Access) ? ::ActiveModel::Access : Access
    end
  end

  def self.inherited(subclass)
    super

    subclass.include Mixins.api
    subclass.include Mixins.access

    subclass.include ::ActiveModel::Attributes
    subclass.include ::ActiveModel::Dirty
    subclass.include ::ActiveModel::Validations::Callbacks
  end

  def inspect
    "#<#{self.class.name} #{attributes.map { |k, v| "#{k}=#{v.inspect}" }.join(" ")}>"
  end
end
