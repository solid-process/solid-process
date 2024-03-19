# frozen_string_literal: true

require "test_helper"

class Solid::Process::ConfigTest < ActiveSupport::TestCase
  class MyInput
    include Solid::Model
  end

  class MyDeps
    include Solid::Model
  end

  test ".configuration" do
    original_config_instance = Solid::Process::Config.instance

    new_config = Solid::Process::Config.new

    Solid::Process::Config.instance_variable_set(:@instance, new_config)

    assert_same new_config, Solid::Process.config

    Solid::Process.configuration do |config|
      assert_same new_config, config

      refute_predicate config, :frozen?
    end

    assert_predicate new_config, :frozen?
  ensure
    Solid::Process::Config.instance_variable_set(:@instance, original_config_instance)
  end

  test ".config" do
    assert_instance_of Solid::Process::Config, Solid::Process.config

    assert_same Solid::Process::Config.instance, Solid::Process.config
  end

  test "config.input_class=" do
    original_input_class = Solid::Process.config.input_class

    Solid::Process.config.input_class = MyInput

    assert_equal MyInput, Solid::Process.config.input_class

    klass = Class.new(Solid::Process) do
      deps do
        attribute :bar
      end

      input do
        attribute :foo
      end

      def self.name
        "MyProcess"
      end
    end

    assert_operator klass.input, :<, MyInput
    assert_operator klass.dependencies, :<, ::Solid::Input
  ensure
    Solid::Process.config.input_class = original_input_class
  end

  test "config.dependencies_class=" do
    original_dependencies_class = Solid::Process.config.dependencies_class

    Solid::Process.config.dependencies_class = MyDeps

    assert_equal MyDeps, Solid::Process.config.dependencies_class

    klass = Class.new(Solid::Process) do
      deps do
        attribute :bar
      end

      input do
        attribute :foo
      end

      def self.name
        "MyProcess"
      end
    end

    assert_operator klass.input, :<, ::Solid::Input
    assert_operator klass.dependencies, :<, MyDeps
  ensure
    Solid::Process.config.dependencies_class = original_dependencies_class
  end
end
