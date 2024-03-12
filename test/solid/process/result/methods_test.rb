# frozen_string_literal: true

require "test_helper"

class Solid::Process::ResultMethodsTest < ActiveSupport::TestCase
  test "Solid::Success() with type" do
    result = Solid::Success(:ok)

    assert_instance_of(BCDD::Result::Context::Success, result)
    assert_kind_of(Solid::Success, result)

    assert result.success?(:ok)
    assert_empty result.value
    assert_instance_of Hash, result.value
  end

  test "Solid::Success() with type and value" do
    result = Solid::Success(:ok, one: 1)

    assert_instance_of(BCDD::Result::Context::Success, result)
    assert_kind_of(Solid::Success, result)

    assert result.success?(:ok)
    assert_equal({one: 1}, result.value)
  end

  test "Solid::Failure() with type" do
    result = Solid::Failure(:err)

    assert_instance_of(BCDD::Result::Context::Failure, result)
    assert_kind_of(Solid::Failure, result)

    assert result.failure?(:err)
    assert_empty result.value
    assert_instance_of Hash, result.value
  end

  test "Solid::Failure() with type and value" do
    result = Solid::Failure(:err, zero: 0)

    assert_instance_of(BCDD::Result::Context::Failure, result)
    assert_kind_of(Solid::Failure, result)

    assert result.failure?(:err)
    assert_equal({zero: 0}, result.value)
  end
end
