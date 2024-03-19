# frozen_string_literal: true

class Solid::Process
  module Callbacks
    def self.included(subclass)
      subclass.include ActiveSupport::Callbacks

      subclass.define_callbacks(:call, :success, :failure)

      subclass.extend ClassMethods
    end

    module ClassMethods
      def before_call(*filters, &block)
        set_callback(:call, :before, *filters, &block)
      end

      def around_call(*filters, &block)
        set_callback(:call, :around, *filters, &block)
      end

      def after_call(*filters, &block)
        set_callback(:call, :after, *filters, &block)
      end

      def after_success(*filters, &block)
        set_callback(:success, :after, *filters, &block)
      end

      def after_failure(*filters, &block)
        set_callback(:failure, :after, *filters, &block)
      end
    end
  end
end
