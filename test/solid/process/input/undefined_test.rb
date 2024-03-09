# frozen_string_literal: true

require "test_helper"

class Solid::Process::InputUndefinedTest < ActiveSupport::TestCase
  Foo = Class.new(Solid::Process)

  test "the error when the input is undefined" do
    error = assert_raises(Solid::Process::Error) do
      Foo.call
    end

    assert_match(
      /.+Foo::Input is undefined. Use .+Foo.input { ... } to define it./,
      error.message
    )
  end
end
