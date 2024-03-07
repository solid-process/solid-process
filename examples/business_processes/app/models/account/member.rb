# frozen_string_literal: true

class Account::Member < ActiveRecord::Base
  self.table_name = "account_members"

  enum role: {owner: 0, admin: 1, contributor: 2}

  belongs_to :user, inverse_of: :memberships
  belongs_to :account, inverse_of: :memberships
end
