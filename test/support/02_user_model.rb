# frozen_string_literal: true

class User < ActiveRecord::Base
  has_secure_password
end
