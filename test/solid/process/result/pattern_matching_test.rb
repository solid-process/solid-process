# frozen_string_literal: true

require "test_helper"

class Solid::Process::ResultPatterMatchingTest < ActiveSupport::TestCase
  def setup
    ::User.delete_all
  end

  test "success" do
    input = {name: "\tJohn     Doe \n", email: "   JOHN.doe@email.com", password: "123123123"}

    result = assert_difference(
      -> { User.count } => 1
    ) do
      UserCreation.call(input)
    end

    # --- Solid::Success ---

    case result
    in Solid::Success[:user_created, {user: user}]
      assert_match(TestUtils::UUID_REGEX, user.uuid)
    end

    case result
    in Solid::Success(type: type, value: {user: user})
      assert_equal(:user_created, type)
      assert_match(TestUtils::UUID_REGEX, user.uuid)
    end

    case result
    in Solid::Success(user: user)
      assert_match(TestUtils::UUID_REGEX, user.uuid)
    end

    # --- Solid::Result ---

    case result
    in Solid::Result[:user_created, {user: user}]
      assert_match(TestUtils::UUID_REGEX, user.uuid)
    end

    case result
    in Solid::Result(type: type, value: {user: user})
      assert_equal(:user_created, type)
      assert_match(TestUtils::UUID_REGEX, user.uuid)
    end

    case result
    in Solid::Result(user: user)
      assert_match(TestUtils::UUID_REGEX, user.uuid)
    end
  end

  test "failure (invalid_input)" do
    input = {name: "     ", email: "John", password: "123123"}

    result = assert_no_difference(
      -> { User.count }
    ) do
      UserCreation.call(input)
    end

    # --- Solid::Failure ---

    case result
    in Solid::Failure[:invalid_input, {input: input}]
      assert_kind_of Solid::Input, input
      assert_instance_of UserCreation::Input, input
    end

    case result
    in Solid::Failure(type: type, value: {input: input})
      assert_equal(:invalid_input, type)
      assert_kind_of Solid::Input, input
      assert_instance_of UserCreation::Input, input
    end

    case result
    in Solid::Failure(input: input)
      assert_kind_of Solid::Input, input
      assert_instance_of UserCreation::Input, input
    end

    # --- Solid::Result ---

    case result
    in Solid::Result[:invalid_input, {input: input}]
      assert_kind_of Solid::Input, input
      assert_instance_of UserCreation::Input, input
    end

    case result
    in Solid::Result(type: type, value: {input: input})
      assert_equal(:invalid_input, type)
      assert_kind_of Solid::Input, input
      assert_instance_of UserCreation::Input, input
    end

    case result
    in Solid::Result(input: input)
      assert_kind_of Solid::Input, input
      assert_instance_of UserCreation::Input, input
    end
  end
end
