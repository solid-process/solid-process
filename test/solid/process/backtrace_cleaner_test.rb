# frozen_string_literal: true

require "test_helper"

class Solid::Process::BacktraceCleanerTest < ActiveSupport::TestCase
  setup do
    @backtrace_cleaner = Solid::Process::BacktraceCleaner.new

    # This silencer is unnecessary in an application as solid-process will be a gem.
    @backtrace_cleaner.add_silencer { |line| line.match?(/lib\/solid\/process/) }
  end

  teardown do
    RuntimeBreaker.reset!

    Account::Member.delete_all
    User::Token.delete_all
    Account.delete_all
    User.delete_all
  end

  test "should clean backtrace" do
    RuntimeBreaker.interruption = "USER_TOKEN_CREATION"

    exception = nil

    assert_no_difference([
      -> { Account::Member.count },
      -> { User::Token.count },
      -> { Account.count },
      -> { User.count }
    ]) do
      exception = assert_raises(RuntimeBreaker::Interruption) do
        Account::OwnerCreation.call(
          owner: {
            name: "John Doe",
            email: "email@johndoe.com",
            password: "password",
            password_confirmation: "password"
          }
        )
      end
    end

    cleaned_backtrace = @backtrace_cleaner.clean(exception.backtrace)

    [
      /runtime_breaker.rb:16:in .*try_to_interrupt'/,
      /user_token_creation.rb:28:in .*create_token_if_not_exists'/,
      /user_token_creation.rb:15:in .*call'/,
      /user_creation.rb:61:in .*create_user_token'/,
      /user_creation.rb:30:in .*call'/,
      /account_owner_creation.rb:32:in .*create_owner'/,
      /account_owner_creation.rb:21:in .*call'/
    ].each_with_index do |pattern, index|
      assert_match pattern, cleaned_backtrace[index]
    end
  end
end
