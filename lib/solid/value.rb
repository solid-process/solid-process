# frozen_string_literal: true

module Solid::Value
  module ClassMethods
    UNDEFINED = ::Object.new

    def new(value = UNDEFINED)
      return value if value.is_a?(self)

      UNDEFINED.equal?(value) ? super() : super(value: value)
    end

    def attribute(...)
      super(:value, ...)
    end

    def validates(...)
      super(:value, ...)
    end
  end

  def self.included(subclass)
    subclass.include Solid::Model
    subclass.extend ClassMethods
    subclass.attribute
  end

  def ==(other)
    other.is_a?(self.class) && other.value == value
  end

  def hash
    value.hash
  end

  def to_s
    value.to_s
  end

  alias_method :eql?, :==
end
