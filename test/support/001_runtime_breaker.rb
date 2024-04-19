# frozen_string_literal: true

module RuntimeBreaker
  Interruption = Class.new(StandardError)

  class << self
    attr_accessor :interruption

    def reset!
      self.interruption = nil
    end

    def try_to_interrupt(interruption)
      return unless interruption == self.interruption

      raise Interruption, "Runtime breaker activated (#{interruption})"
    end
  end
end
