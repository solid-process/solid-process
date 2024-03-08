# frozen_string_literal: true

module TestUtils
  UUID_REGEX = /\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/.freeze
  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/.freeze
end
