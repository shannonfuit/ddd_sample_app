# frozen_string_literal: true

module Infra
  class ProcessTestHelper < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    attr_reader :event_store, :command_bus

    def before_setup
      super
      @command_bus = Infra::CommandBus.fake
      @event_store = Infra::EventStore.in_memory
    end

    private

    def assert_command(command)
      assert_equal(command, command_bus.received)
    end

    def assert_all_commands(*commands)
      assert_equal(commands, command_bus.all_received)
    end

    def assert_no_command
      assert_nil(command_bus.received)
    end

    def given(events, store: event_store)
      events.each { |ev| store.append(ev) }
      events
    end
  end
end
