# frozen_string_literal: true

require "test_helper"

class Solid::Process::RescueFromTest < ActiveSupport::TestCase
  class Division < Solid::Process
    NanNumberError = Class.new(StandardError)
    InfiniteNumberError = Class.new(StandardError)
    NumeratorIsZeroError = Class.new(StandardError)

    input do
      attribute :number1
      attribute :number2
    end

    rescue_from ZeroDivisionError do |error|
      Failure!(:zero_division_error, error: error)
    end

    rescue_from NumeratorIsZeroError do
      Success!(:division_completed, result: 0)
    end

    rescue_from NanNumberError, with: :nan_number_error

    rescue_from InfiniteNumberError, with: :infinite_number_error

    def call(attributes)
      number1 = attributes.fetch(:number1)
      number2 = attributes.fetch(:number2)

      raise NanNumberError if nan?(number1) || nan?(number2)
      raise InfiniteNumberError if infinite?(number1) || infinite?(number2)
      raise NumeratorIsZeroError if number1.zero? && number2.zero?

      Success(:division_completed, result: number1 / number2)
    end

    private

    def nan?(number)
      number.respond_to?(:nan?) && number.nan?
    end

    def infinite?(number)
      !number.respond_to?(:infinite?) || number.infinite?
    end

    def nan_number_error(error)
      # This is a contrived example to test the error when Failure! is called twice or more.
      2.times { Failure!(:nan_number_error, error: error) }
    end

    def infinite_number_error(error)
      # This is a contrived example to test the error when Success! is called twice or more.
      2.times { Success!(:infinite_number_error, error: error) }
    end
  end

  test "rescue from ZeroDivisionError" do
    result = Division.call(number1: 1, number2: 0)

    assert result.failure?(:zero_division_error)
    assert_instance_of ZeroDivisionError, result.value[:error]
  end

  test "rescue from NumeratorIsZeroError" do
    result = Division.call(number1: 0, number2: 0)

    assert result.success?(:division_completed)
    assert_equal 0, result.value[:result]
  end

  test "rescue from NanNumberError" do
    err = assert_raises(Solid::Process::Error) do
      Division.call(number1: Float::NAN, number2: 1)
    end

    assert_equal "`Failure!()` cannot be called because the `#{Division}#output` is already set.", err.message
  end

  test "rescue from InfiniteNumberError" do
    err = assert_raises(Solid::Process::Error) do
      Division.call(number1: Float::INFINITY, number2: 1)
    end

    assert_equal "`Success!()` cannot be called because the `#{Division}#output` is already set.", err.message
  end
end
