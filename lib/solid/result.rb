# frozen_string_literal: true

module Solid
  Output = ::BCDD::Context

  Result = ::BCDD::Context
  Success = Result::Success
  Failure = Result::Failure

  def self.Success(...)
    Result::Success(...)
  end

  def self.Failure(...)
    Result::Failure(...)
  end
end
