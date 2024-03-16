# frozen_string_literal: true

class Solid::Input
  require_relative "model"

  def self.inherited(subclass)
    subclass.include(::Solid::Model)
  end

  def self.[](...)
    new(...)
  end
end
