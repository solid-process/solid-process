# frozen_string_literal: true

class Solid::Process::BacktraceCleaner < ActiveSupport::BacktraceCleaner
  def initialize
    super

    add_blocks_silencer
  end

  private

  BLOCKS_PATTERN = /block \(\d+ levels?\) in|in `block in|in `then'|internal:kernel/.freeze

  def add_blocks_silencer
    add_silencer { |line| line.match?(BLOCKS_PATTERN) }
  end
end
