# frozen_string_literal: true

require_relative "model/access"

module Solid::Model
  extend ::ActiveSupport::Concern

  module ClassMethods
    def [](...)
      new(...)
    end

    def inherited(subclass)
      subclass.include(::Solid::Model)
    end
  end

  included do
    include ::ActiveModel.const_defined?(:Api, false) ? ::ActiveModel::Api : ::ActiveModel::Model
    include ::ActiveModel.const_defined?(:Access, false) ? ::ActiveModel::Access : ::Solid::Model::Access

    include ::ActiveModel::Attributes
    include ::ActiveModel::Dirty
    include ::ActiveModel::Validations::Callbacks

    extend ActiveModel::Callbacks

    define_model_callbacks :initialize, only: :after
  end

  def initialize(...)
    super(...)

    run_callbacks(:initialize)
  end

  def inspect
    "#<#{self.class.name} #{attributes.map { |k, v| "#{k}=#{v.inspect}" }.join(" ")}>"
  end
end
