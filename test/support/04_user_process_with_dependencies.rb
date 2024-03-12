# frozen_string_literal: true

class CreateUser < Solid::Process
  dependencies do
    attribute :repository, default: ::User

    validate :repository_interface

    def repository_interface
      repository.respond_to?(:create!) or errors.add(:repository, message: "must respond to :create!")
      repository.respond_to?(:exists?) or errors.add(:repository, message: "must respond to :exists?")
    end
  end

  input do
    attribute :uuid, :string, default: -> { ::SecureRandom.uuid }
    attribute :name, :string
    attribute :email, :string
    attribute :password, :string
    attribute :executed_at, :time, default: -> { ::Time.current }

    before_validation do |input|
      input.uuid = input.uuid.strip.downcase
      input.name = input.name&.strip&.gsub(/\s+/, " ")
      input.email = input.email&.strip&.downcase
    end

    validates :name, presence: true
    validates :uuid, presence: true, format: {with: TestUtils::UUID_REGEX}
    validates :email, presence: true, format: {with: TestUtils::EMAIL_REGEX}
    validates :password, presence: true
  end

  def call(input)
    rollback_on_failure do
      Given(input)
        .and_then(:validate_email_has_not_been_taken)
        .and_then(:create_user)
        .and_expose(:user_created, %i[user])
    end
  end

  private

  def validate_email_has_not_been_taken(email:, **)
    dependencies.repository.exists?(email: email) ? Failure(:email_already_taken) : Continue()
  end

  def create_user(uuid:, name:, email:, password:, executed_at:)
    user = dependencies.repository.create!(
      uuid: uuid,
      name: name,
      email: email,
      password: password,
      created_at: executed_at,
      updated_at: executed_at
    )

    Continue(user: user)
  end
end
