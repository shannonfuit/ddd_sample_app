# frozen_string_literal: true

require_relative '../lib/processes'

module Processes
  class Test < ActiveSupport::TestCase
    # include Infra::TestPlumbing.with(
    #   event_store: -> { Infra::EventStore.in_memory },
    #   command_bus: -> { FakeCommandBus.new }
    # )

    def before_setup
      super
      @command_bus = FakeCommandBus.new
      @event_store = Rails.configuration.event_store
      Configuration.new.call(event_store, command_bus)
    end

    attr_reader :event_store, :command_bus

    def assert_command(command)
      assert_equal(command, @command_bus.received)
    end

    def assert_all_commands(*commands)
      assert_equal(commands, @command_bus.all_received)
    end

    def assert_no_command
      assert_nil(@command_bus.received)
    end

    private

    class FakeCommandBus
      attr_reader :received, :all_received

      def initialize
        @all_received = []
      end

      def call(command)
        @received = command
        @all_received << command
      end

      def clear_all_received
        @all_received = []
        @received = nil
      end
    end

    def given(events, store: event_store)
      events.each { |ev| store.append(ev) }
      events
    end
  end
end
