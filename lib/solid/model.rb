# frozen_string_literal: true

module Solid::Model
  require_relative "model/access"

  extend ::ActiveSupport::Concern

  included do
    include ::ActiveModel.const_defined?(:Api, false) ? ::ActiveModel::Api : ::ActiveModel::Model
    include ::ActiveModel.const_defined?(:Access, false) ? ::ActiveModel::Access : ::Solid::Model::Access

    include ::ActiveModel::Attributes
    include ::ActiveModel::Dirty
    include ::ActiveModel::Validations::Callbacks
  end

  def inspect
    "#<#{self.class.name} #{attributes.map { |k, v| "#{k}=#{v.inspect}" }.join(" ")}>"
  end
end
