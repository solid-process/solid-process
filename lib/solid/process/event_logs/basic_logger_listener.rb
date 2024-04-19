# frozen_string_literal: true

class Solid::Process::EventLogs::BasicLoggerListener
  include ActiveSupport::Configurable
  include Solid::Result::EventLogs::Listener

  config_accessor(:logger, :backtrace_cleaner)

  self.logger = ActiveSupport::Logger.new($stdout)
  self.backtrace_cleaner = Solid::Process::BacktraceCleaner.new

  module MessagesNesting
    MAP_STEP_METHOD = lambda do |record_result|
      kind, type, value = record_result.values_at(:kind, :type, :value)

      value_keys = "#{value.keys.join(":, ")}:"
      value_keys = "" if value_keys == ":"

      case type
      when :_given_ then "Given(#{value_keys})"
      when :_continue_ then "Continue(#{value_keys})"
      else "#{kind.capitalize}(:#{type}, #{value_keys})"
      end
    end

    MAP_STEP_MESSAGE = lambda do |record|
      step = MAP_STEP_METHOD[record[:result]]

      method_name = record.dig(:and_then, :method_name)

      " * #{step} from method: #{method_name}".chomp("from method: ").chomp(" ")
    end

    MAP_IDS_WITH_MESSAGES = lambda do |records|
      process_ids = []

      records.each_with_object([]) do |record, messages|
        current = record[:current]

        current_id = current[:id]

        unless process_ids.include?(current_id)
          process_ids << current_id

          id, name, desc = current.values_at(:id, :name, :desc)

          messages << [current_id, "##{id} #{name} - #{desc}".chomp("- ").chomp(" ")]
        end

        messages << [current_id, MAP_STEP_MESSAGE[record]]
      end
    end

    def self.map(event_logs)
      ids_level_parent = event_logs.dig(:metadata, :ids, :level_parent)

      messages = MAP_IDS_WITH_MESSAGES[event_logs[:records]]

      messages.map { |(id, msg)| "#{"   " * ids_level_parent[id].first}#{msg}" }
    end
  end

  def on_finish(event_logs:)
    messages = MessagesNesting.map(event_logs)

    logger.info messages.join("\n")
  end

  def before_interruption(exception:, event_logs:)
    messages = MessagesNesting.map(event_logs)

    logger.info messages.join("\n")

    cleaned_backtrace = backtrace_cleaner.clean(exception.backtrace).join("\n  ")

    logger.error "\nException:\n  #{exception.message} (#{exception.class})\n\nBacktrace:\n  #{cleaned_backtrace}"
  end
end
