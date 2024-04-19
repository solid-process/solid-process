# frozen_string_literal: true

require "solid/result"

module Solid
  def self.Success(...)
    ::Solid::Output::Success(...)
  end

  def self.Failure(...)
    ::Solid::Output::Failure(...)
  end
end
