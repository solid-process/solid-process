# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require "db/setup"

require "app/models/account"
require "app/models/account/member"
require "app/models/user"
require "app/models/user/token"

require "app/models/account/owner_creation"
require "app/models/user/token/creation"
require "app/models/user/creation"
