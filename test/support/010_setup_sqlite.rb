# frozen_string_literal: true

require "active_support/all"
require "active_record"

ActiveRecord::Base.establish_connection(
  host: "localhost",
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.define do
  suppress_messages do
    create_table :accounts do |t|
      t.string :uuid, null: false, index: {unique: true}

      t.timestamps
    end

    create_table :users do |t|
      t.string :uuid, null: false, index: {unique: true}
      t.string :name, null: false
      t.string :email, null: false, index: {unique: true}
      t.string :password_digest, null: false

      t.timestamps
    end

    create_table :user_tokens do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.datetime :access_token_expires_at, null: false
      t.datetime :refresh_token_expires_at, null: false

      t.timestamps
    end

    create_table :account_members do |t|
      t.integer :role, null: false, default: 0
      t.belongs_to :user, null: false, foreign_key: true, index: true
      t.belongs_to :account, null: false, foreign_key: true, index: true

      t.timestamps

      t.index %i[account_id role], unique: true, where: "(role = 0)"
      t.index %i[account_id user_id], unique: true
    end
  end
end
