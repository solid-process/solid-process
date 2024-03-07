# frozen_string_literal: true

class User
  class Creation < Solid::Process
    input do
      attribute :uuid, :string, default: -> { ::SecureRandom.uuid }
      attribute :name, :string
      attribute :email, :string
      attribute :password, :string
      attribute :password_confirmation, :string

      before_validation do |input|
        input.uuid = input.uuid.strip.downcase
        input.name = input.name.strip.gsub(/\s+/, " ")
        input.email = input.email.strip.downcase
      end

      validates :uuid, presence: true, format: {with: /\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/i}
      validates :name, presence: true
      validates :email, presence: true, format: {with: ::URI::MailTo::EMAIL_REGEXP}
      validates :password, :password_confirmation, presence: true
    end

    def call(attributes)
      Given(attributes)
        .and_then(:validate_email_uniqueness)
        .then { |result|
          rollback_on_failure {
            result
              .and_then(:create_user)
              .and_then(:create_user_token)
          }
        }
        .and_expose(:user_created, %i[user token])
    end

    private

    def validate_email_uniqueness(email:, **)
      ::User.exists?(email:) ? Failure(:email_already_taken) : Continue()
    end

    def create_user(uuid:, name:, email:, password:, password_confirmation:)
      user = ::User.create(uuid:, name:, email:, password:, password_confirmation:)

      user.persisted? ? Continue(user:) : Failure(:invalid_record, **user.errors.messages)
    end

    def create_user_token(user:, **)
      Token::Creation.call(user: user).handle do |on|
        on.success { |output| Continue(token: output[:token]) }
        on.failure { raise "Token creation failed" }
      end
    end
  end
end
