# frozen_string_literal: true

class Solid::Process
  module Callbacks
    def self.included(subclass)
      subclass.include ActiveSupport::Callbacks

      subclass.define_callbacks(:success, :failure, :output)

      subclass.extend ClassMethods
    end

    module ClassMethods
      def after_success(*args, &block)
        options = args.extract_options!
        options = options.dup
        options[:prepend] = true

        set_callback(:success, :after, *args, options, &block)
      end

      def after_failure(*args, &block)
        options = args.extract_options!
        options = options.dup
        options[:prepend] = true

        set_callback(:failure, :after, *args, options, &block)
      end

      def after_output(*args, &block)
        options = args.extract_options!
        options = options.dup
        options[:prepend] = true

        set_callback(:output, :after, *args, options, &block)
      end

      alias_method :after_result, :after_output
    end
  end
end
