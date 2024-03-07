# frozen_string_literal: true

class Account < ActiveRecord::Base
  has_many :memberships, inverse_of: :account, dependent: :destroy, class_name: "::Account::Member"
  has_many :users, through: :memberships, inverse_of: :accounts

  where_ownership = -> { where(account_members: {role: :owner}) }

  has_one :ownership, where_ownership, dependent: nil, inverse_of: :account, class_name: "::Account::Member"
  has_one :owner, through: :ownership, source: :user
end
