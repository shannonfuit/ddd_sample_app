# frozen_string_literal: true

module Infra
  class DomainTestHelper < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    attr_reader :event_store, :command_bus

    def before_setup
      super
      @event_store = Infra::EventStore.main
      @command_bus = Infra::CommandBus.main

      AggregateRoot.configure { |config| config.default_event_store = event_store }
    end

    def assert_events(actual_events, expected_events)
      expects = expected_events.map(&:data)
      assert_equal(expects, actual_events.map(&:data))
    end

    def assert_no_events(actual_events)
      assert_empty(actual_events)
    end

    def arrange(stream, events)
      events.each { |ev| event_store.publish(ev, stream_name: stream) }
    end

    def act(stream, command)
      before = event_store.read.stream(stream).each.to_a
      command_bus.call(command)
      after = event_store.read.stream(stream).each.to_a
      after.reject { |a| before.any? { |b| a.event_id == b.event_id } }
    end
  end
end
