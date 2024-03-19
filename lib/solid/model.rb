# frozen_string_literal: true

require_relative "model/access"

module Solid::Model
  extend ::ActiveSupport::Concern

  included do
    include ::ActiveModel.const_defined?(:Api, false) ? ::ActiveModel::Api : ::ActiveModel::Model
    include ::ActiveModel.const_defined?(:Access, false) ? ::ActiveModel::Access : ::Solid::Model::Access

    include ::ActiveModel::Attributes
    include ::ActiveModel::Dirty
    include ::ActiveModel::Validations::Callbacks
  end

  module ClassMethods
    def [](...)
      new(...)
    end

    def inherited(subclass)
      subclass.include(::Solid::Model)
    end
  end

  def inspect
    "#<#{self.class.name} #{attributes.map { |k, v| "#{k}=#{v.inspect}" }.join(" ")}>"
  end
end
