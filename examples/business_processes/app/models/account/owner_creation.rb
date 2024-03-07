# frozen_string_literal: true

class Account
  class OwnerCreation < Solid::Process
    input do
      attribute :uuid, :string, default: -> { ::SecureRandom.uuid }
      attribute :owner

      before_validation do |input|
        input.uuid = input.uuid.strip.downcase
      end

      validates :uuid, presence: true, format: {with: /\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/i}
      validates :owner, presence: true, type: ::Hash
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
      ::User::Creation.call(owner).handle do |on|
        on.success { |output| Continue(user: output[:user], user_token: output[:token]) }
        on.failure { |output| Failure(:invalid_owner, **output) }
      end
    end

    def create_account(uuid:, **)
      account = ::Account.create(uuid:)

      account.persisted? ? Continue(account:) : Failure(:invalid_record, **account.errors.messages)
    end

    def link_owner_to_account(account:, user:, **)
      Member.create!(account:, user:, role: :owner)

      Continue()
    end
  end
end
