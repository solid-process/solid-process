# frozen_string_literal: true

require "test_helper"

class Solid::Process::EventLogs::BasicLoggerListenerTest < ActiveSupport::TestCase
  # This silencer is unnecessary in an application as solid-process will be a gem.
  Solid::Process::EventLogs::BasicLoggerListener
    .backtrace_cleaner
    .add_silencer { |line| line.match?(/lib\/solid\/process/) }

  setup do
    @original_listener = Solid::Result.config.event_logs.listener
    @original_logger = Solid::Process::EventLogs::BasicLoggerListener.logger
    @stdout = StringIO.new

    Solid::Result.config.event_logs.listener = Solid::Process::EventLogs::BasicLoggerListener

    Solid::Process::EventLogs::BasicLoggerListener.logger = ActiveSupport::Logger.new(@stdout)
  end

  teardown do
    Solid::Result.config.event_logs.listener = @original_listener

    Solid::Process::EventLogs::BasicLoggerListener.logger = @original_logger

    RuntimeBreaker.reset!

    Account::Member.delete_all
    User::Token.delete_all
    Account.delete_all
    User.delete_all
  end

  test ".backtrace_cleaner" do
    assert_instance_of(
      Solid::Process::BacktraceCleaner,
      Solid::Process::EventLogs::BasicLoggerListener.backtrace_cleaner
    )
  end

  test ".logger" do
    assert_instance_of(
      ActiveSupport::Logger,
      Solid::Process::EventLogs::BasicLoggerListener.logger
    )
  end

  test "should log events" do
    Account::OwnerCreation.call(
      owner: {
        name: "John Doe",
        email: "email@johndoe.com",
        password: "password",
        password_confirmation: "password"
      }
    )

    stdout_lines = @stdout.string.split("\n")

    [
      "#0 Account::OwnerCreation",
      " * Given(uuid:, owner:)",
      "   #1 User::Creation",
      "    * Given(uuid:, name:, email:, password:, password_confirmation:)",
      "    * Continue() from method: validate_email_uniqueness",
      "    * Continue(user:) from method: create_user",
      "      #2 User::Token::Creation",
      "       * Given(user:, executed_at:)",
      "       * Continue() from method: validate_token_existence",
      "       * Continue(token:) from method: create_token_if_not_exists",
      "       * Success(:token_created, token:)",
      "    * Continue(token:) from method: create_user_token",
      "    * Success(:user_created, user:, token:)",
      " * Continue(user:, user_token:) from method: create_owner",
      " * Continue(account:) from method: create_account",
      " * Continue() from method: link_owner_to_account",
      " * Success(:account_owner_created, user:, account:)"
    ].each_with_index do |message, index|
      assert_equal message, stdout_lines[index]
    end
  end

  test "should log events with a backtrace when an exception is raised" do
    RuntimeBreaker.interruption = "USER_TOKEN_CREATION"

    assert_raises(RuntimeBreaker::Interruption) do
      Account::OwnerCreation.call(
        owner: {
          name: "John Doe",
          email: "email@johndoe.com",
          password: "password",
          password_confirmation: "password"
        }
      )
    end

    stdout_lines = @stdout.string.split("\n")

    [
      "#0 Account::OwnerCreation",
      " * Given(uuid:, owner:)",
      "   #1 User::Creation",
      "    * Given(uuid:, name:, email:, password:, password_confirmation:)",
      "    * Continue() from method: validate_email_uniqueness",
      "    * Continue(user:) from method: create_user",
      "      #2 User::Token::Creation",
      "       * Given(user:, executed_at:)",
      "       * Continue() from method: validate_token_existence",
      "",
      "Exception:",
      "  Runtime breaker activated (USER_TOKEN_CREATION) (RuntimeBreaker::Interruption)",
      "",
      "Backtrace:",
      /runtime_breaker.rb:16:in .*try_to_interrupt'/,
      /user_token_creation.rb:28:in .*create_token_if_not_exists'/,
      /user_token_creation.rb:15:in .*call'/,
      /user_creation.rb:61:in .*create_user_token'/,
      /user_creation.rb:30:in .*call'/,
      /account_owner_creation.rb:32:in .*create_owner'/,
      /account_owner_creation.rb:21:in .*call'/
    ].each_with_index do |message, index|
      assert_match message, stdout_lines[index]
    end
  end
end
