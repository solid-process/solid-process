# frozen_string_literal: true

class User < ActiveRecord::Base
  has_secure_password

  has_many :memberships, inverse_of: :user, dependent: :destroy, class_name: "::Account::Member"
  has_many :accounts, through: :memberships, inverse_of: :users

  where_ownership = -> { where(account_members: {role: :owner}) }

  has_one :ownership, where_ownership, inverse_of: :user, class_name: "::Account::Member"
  has_one :account, through: :ownership, inverse_of: :owner

  has_one :token, inverse_of: :user, dependent: :destroy, class_name: "::User::Token"
end
