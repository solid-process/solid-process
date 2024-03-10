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
    create_table :users do |t|
      t.string :uuid, null: false, index: {unique: true}
      t.string :name, null: false
      t.string :email, null: false, index: {unique: true}
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
