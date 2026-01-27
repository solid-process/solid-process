# frozen_string_literal: true

class Account < ActiveRecord::Base
  has_many :memberships, inverse_of: :account, dependent: :destroy, class_name: "::Account::Member"
  has_many :users, through: :memberships, inverse_of: :accounts

  where_ownership = -> { where(account_members: {role: :owner}) }

  has_one :ownership, where_ownership, dependent: nil, inverse_of: :account, class_name: "::Account::Member"
  has_one :owner, through: :ownership, source: :user
end

class User < ActiveRecord::Base
  has_secure_password

  has_many :memberships, inverse_of: :user, dependent: :destroy, class_name: "::Account::Member"
  has_many :accounts, through: :memberships, inverse_of: :users

  where_ownership = -> { where(account_members: {role: :owner}) }

  has_one :ownership, where_ownership, inverse_of: :user, class_name: "::Account::Member"
  has_one :account, through: :ownership, inverse_of: :owner

  has_one :token, inverse_of: :user, dependent: :destroy, class_name: "::User::Token"
end

class User::Token < ActiveRecord::Base
  self.table_name = "user_tokens"

  belongs_to :user, inverse_of: :token
end

class Account::Member < ActiveRecord::Base
  self.table_name = "account_members"

  if ActiveRecord.version.to_s >= "8.0"
    enum :role, owner: 0, admin: 1, contributor: 2
  else
    enum role: {owner: 0, admin: 1, contributor: 2}
  end

  belongs_to :user, inverse_of: :memberships
  belongs_to :account, inverse_of: :memberships
end
