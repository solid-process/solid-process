# frozen_string_literal: true

class Account
  class OwnerCreation < Solid::Process
    deps do
      attribute :user_creation, default: ::User::Creation
    end

    input do
      attribute :uuid, :string, default: -> { ::SecureRandom.uuid }
      attribute :owner

      before_validation do |input|
        input.uuid = input.uuid.strip.downcase
      end

      validates :uuid, presence: true, format: {with: /\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/i}
      validates :owner, presence: true
    end

    def call(attributes)
      rollback_on_failure {
        Given(attributes)
          .and_then(:create_owner)
          .and_then(:create_account)
          .and_then(:link_owner_to_account)
      }.and_expose(:account_owner_created, %i[user account])
    end

    private

    def create_owner(owner:, **)
      case deps.user_creation.call(owner)
      in Solid::Success(user:, token:)
        Continue(user:, user_token: token)
      in Solid::Failure(type:, value:)
        Failure(:invalid_owner, **{type => value})
      end
    end

    def create_account(uuid:, **)
      account = ::Account.create(uuid:)

      account.persisted? ? Continue(account:) : Failure(:invalid_account, account:)
    end

    def link_owner_to_account(account:, user:, **)
      Member.create!(account:, user:, role: :owner)

      Continue()
    end
  end
end
