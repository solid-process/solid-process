# frozen_string_literal: true

class User::Creation < Solid::Process
  deps do
    attribute :token_creation, default: ::User::Token::Creation
  end

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
    ::User.exists?(email: email) ? Failure(:email_already_taken) : Continue()
  end

  def create_user(uuid:, name:, email:, password:, password_confirmation:)
    ::RuntimeBreaker.try_to_interrupt("USER_CREATION")

    user = ::User.create(
      uuid: uuid,
      name: name,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )

    user.persisted? ? Continue(user: user) : Failure(:invalid_record, **user.errors.messages)
  end

  def create_user_token(user:, **)
    case deps.token_creation.call(user: user)
    in Solid::Success(token: token)
      Continue(token: token)
    in Solid::Failure
      raise "Token creation failed"
    end
  end
end
