# frozen_string_literal: true

require "test_helper"

class Solid::Process::InheritanceTest < ActiveSupport::TestCase
  class Foo < Solid::Process
    input do
      attribute :bar, :string
    end
  end

  test "the error when the #call is not implemented" do
    error = assert_raises(Solid::Process::Error) do
      Foo.call
    end

    assert_match(/.+Foo#call must be implemented\./, error.message)
  end
end
