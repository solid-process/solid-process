# frozen_string_literal: true

require "test_helper"

class Solid::Process::ProcessInstanceTest < ActiveSupport::TestCase
  def setup
    ::User.delete_all
  end

  test "#call when the output is already set" do
    user_creation = UserCreation.new

    user_creation.call(name: nil, email: nil)

    err = assert_raises(Solid::Process::Error) do
      user_creation.call(name: nil, email: nil)
    end

    assert_equal(
      "The `UserCreation#output` is already set. " \
      "Use `.output` to access the result or create a new instance to call again.",
      err.message
    )
  end

  test "#new" do
    user_creation = UserCreation.new

    user_creation.call(name: nil, email: nil)

    assert_raises(Solid::Process::Error) { user_creation.call(name: nil, email: nil) }

    new_user_creation = user_creation.new

    assert new_user_creation.call(name: nil, email: nil).failure?(:invalid_input)

    assert_difference(-> { User.count } => 1) do
      new_user_creation.new.call(name: "Foo", email: "foo@foo.com", password: "123123123")
    end

    # ---

    create_user = CreateUser.new

    create_user.call(name: nil, email: nil)

    assert_raises(Solid::Process::Error) { create_user.call(name: nil, email: nil) }

    new_create_user = create_user.new(repository: ::Object)

    assert new_create_user.call(name: nil, email: nil).failure?(:invalid_dependencies)

    assert_difference(-> { User.count } => 1) do
      create_user.new.call(name: "Bar", email: "bar@bar.com", password: "123123123")
    end
  end

  test "#input" do
    user_creation1 = UserCreation.new

    assert_nil user_creation1.input

    user_creation1.call(name: "\tJohn     Doe \n", email: "   JOHN.doe@email.com", password: "123123123")

    assert_match(TestUtils::UUID_REGEX, user_creation1.input.uuid)
    assert_equal("John Doe", user_creation1.input.name)
    assert_equal("john.doe@email.com", user_creation1.input.email)

    # ---

    user_creation2 = UserCreation.new

    assert_nil user_creation2.input

    user_creation2.call(uuid: "", name: nil, email: nil)

    refute_match(TestUtils::UUID_REGEX, user_creation2.input.uuid)
    assert_nil user_creation2.input.name
    assert_nil user_creation2.input.email
  end

  test "#input?" do
    user_creation1 = UserCreation.new

    refute_predicate user_creation1, :input?

    user_creation1.call(name: "\tJohn     Doe \n", email: "   JOHN.doe@email.com", password: "123123123")

    assert_predicate user_creation1, :input?

    # ---

    user_creation2 = UserCreation.new

    refute_predicate user_creation2, :input?

    user_creation2.call(uuid: "", name: nil, email: nil)

    assert_predicate user_creation2, :input?
  end

  test "#output" do
    user_creation1 = UserCreation.new

    assert_nil user_creation1.output
    assert_nil user_creation1.result

    result = user_creation1.call(name: "John Doe", email: "   JOHN.doe@email.com", password: "123123123")

    assert_same result, user_creation1.output
    assert_same result, user_creation1.result

    # ---

    user_creation2 = UserCreation.new

    assert_nil user_creation2.output
    assert_nil user_creation2.result

    result = user_creation2.call(uuid: "", name: nil, email: nil)

    assert_same result, user_creation2.output
    assert_same result, user_creation2.result
  end

  test "#output?" do
    user_creation1 = UserCreation.new

    refute_predicate user_creation1, :output?
    refute_predicate user_creation1, :result?

    refute user_creation1.output?(:user_created)
    refute user_creation1.result?(:user_created)

    user_creation1.call(name: "John Doe", email: "john.doe@email.com", password: "123123123")

    assert_predicate user_creation1, :output?
    assert_predicate user_creation1, :result?

    assert user_creation1.output?(:user_created)
    assert user_creation1.result?(:user_created)

    # ---

    user_creation2 = UserCreation.new

    refute_predicate user_creation2, :output?
    refute_predicate user_creation2, :result?

    refute user_creation2.output?(:invalid_input)
    refute user_creation2.result?(:invalid_input)

    user_creation2.call(uuid: "", name: nil, email: nil)

    assert_predicate user_creation2, :output?
    assert_predicate user_creation2, :result?

    assert user_creation2.output?(:invalid_input)
    assert user_creation2.result?(:invalid_input)
  end

  test "#dependencies" do
    user_creation1 = UserCreation.new

    assert_nil(user_creation1.dependencies)
    assert_nil(user_creation1.deps)

    # ---

    user_creation2 = CreateUser.new

    assert_same(User, user_creation2.dependencies.repository)
    assert_same(user_creation2.dependencies, user_creation2.deps)

    # ---

    user_creation3 = CreateUser.new(repository: ::Object)

    assert_same(::Object, user_creation3.dependencies.repository)
    assert_same(user_creation3.dependencies, user_creation3.deps)
  end

  test "#dependencies?" do
    user_creation1 = UserCreation.new

    refute_predicate user_creation1, :dependencies?
    refute_predicate user_creation1, :deps?

    # ---

    user_creation2 = CreateUser.new

    assert_predicate user_creation2, :dependencies?
    assert_predicate user_creation2, :deps?
  end

  test "#success?" do
    user_creation = UserCreation.new

    refute_predicate user_creation, :success?
    refute user_creation.success?(:user_created)
    refute user_creation.success?(:person_created)

    user_creation.call(name: "John Doe", email: "   JOHN.doe@email.com", password: "123123123")

    assert_predicate user_creation, :success?
    assert user_creation.success?(:user_created)
    refute user_creation.success?(:person_created)
  end

  test "#failure?" do
    user_creation = UserCreation.new

    refute_predicate user_creation, :failure?
    refute user_creation.failure?(:invalid_input)
    refute user_creation.failure?(:invalid_output)

    user_creation.call(uuid: "", name: nil, email: nil)

    assert_predicate user_creation, :failure?
    assert user_creation.failure?(:invalid_input)
    refute user_creation.failure?(:invalid_output)
  end

  test "#inspect" do
    user_creation = UserCreation.new

    assert_equal("#<UserCreation dependencies=nil input=nil output=nil>", user_creation.inspect)
  end

  test "#method_missing" do
    user_creation1 = UserCreation.new

    user_creation1.call(name: "John Doe", email: "john.doe@email.com", password: "123123123")

    assert_predicate user_creation1, :user_created?

    # ---

    user_creation2 = UserCreation.new

    user_creation2.call(uuid: "", name: nil, email: nil)

    assert_predicate user_creation2, :invalid_input?

    # ---

    assert_raises(NoMethodError) { user_creation1.foo }
    assert_raises(NoMethodError) { user_creation2.foo }
  end

  test "#respond_to_missing?" do
    user_creation1 = UserCreation.new

    refute user_creation1.method(:foo?).call
  end

  test "#dependencies=" do
    create_user = CreateUser.allocate

    assert_nil create_user.dependencies

    assert_raises(NoMethodError) do
      create_user.dependencies = {repository: ::User}
    end

    create_user.send(:dependencies=, {repository: ::User})

    assert_predicate create_user, :dependencies?

    assert_same(::User, create_user.dependencies.repository)

    err = assert_raises(Solid::Process::Error) do
      create_user.send(:dependencies=, {repository: ::User})
    end

    assert_equal("The `CreateUser#dependencies` is already set.", err.message)
  end

  test "#input=" do
    user_creation = UserCreation.new

    assert_nil user_creation.input

    assert_raises(NoMethodError) do
      user_creation.input = {name: "John Doe", email: "john@email.com"}
    end

    user_creation.send(:input=, {name: "John Doe", email: "john@email.com"})

    assert_predicate user_creation, :input?

    assert_equal("John Doe", user_creation.input.name)
    assert_equal("john@email.com", user_creation.input.email)

    err = assert_raises(Solid::Process::Error) do
      user_creation.send(:input=, {name: "John Doe", email: "john@email.com"})
    end

    assert_equal("The `UserCreation#input` is already set.", err.message)
  end

  test "#output=" do
    user_creation = UserCreation.new

    assert_nil user_creation.output

    assert_raises(NoMethodError) do
      user_creation.output = Solid::Success(:user_created, user: ::User.new)
    end

    err1 = assert_raises(Solid::Process::Error) do
      user_creation.send(:output=, 1)
    end

    assert_equal("The result 1 must be a BCDD::Context.", err1.message)

    user_creation.send(:output=, Solid::Success(:user_created, user: ::User.new))

    assert_predicate user_creation, :output?

    assert user_creation.output?(:user_created)
    assert_instance_of ::User, user_creation.output.value[:user]

    err2 = assert_raises(Solid::Process::Error) do
      user_creation.send(:output=, Solid::Success(:user_created, user: ::User.new))
    end

    assert_equal(
      "The `UserCreation#output` is already set. " \
      "Use `.output` to access the result or create a new instance to call again.",
      err2.message
    )
  end
end
