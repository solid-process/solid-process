# frozen_string_literal: true

class Solid::Process::BacktraceCleaner < ActiveSupport::BacktraceCleaner
  def initialize
    super

    add_blocks_silencer
  end

  private

  BLOCKS_PATTERN = /in [`']block in|in [`'](?:Kernel#)?then'|internal:kernel|block \(\d+ levels?\) in/.freeze

  def add_blocks_silencer
    add_silencer { |line| line.match?(BLOCKS_PATTERN) }
  end
end
