# frozen_string_literal: true

class User::Token < ActiveRecord::Base
  self.table_name = "user_tokens"

  belongs_to :user, inverse_of: :token
end
