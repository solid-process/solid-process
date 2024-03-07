# frozen_string_literal: true

class User::Token
  class Creation < Solid::Process
    input do
      attribute :user
      attribute :executed_at, :time, default: -> { ::Time.current }

      validates :user, presence: true, type: ::User
      validates :executed_at, presence: true
    end

    def call(attributes)
      Given(attributes)
        .and_then(:validate_token_existence)
        .and_then(:create_token)
        .and_expose(:token_created, %i[token])
    end

    private

    def validate_token_existence(user:, **)
      user.token.nil? ? Continue() : Failure(:token_already_exists)
    end

    def create_token(user:, executed_at:, **)
      token = user.create_token(
        access_token: ::SecureRandom.hex(24),
        refresh_token: ::SecureRandom.hex(24),
        access_token_expires_at: executed_at + 15.days,
        refresh_token_expires_at: executed_at + 30.days
      )

      token.persisted? ? Continue(token:) : Failure(:token_creation_failed, **token.errors.messages)
    end
  end
end
