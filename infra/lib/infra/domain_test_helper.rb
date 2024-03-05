# frozen_string_literal: true

module Infra
  class DomainTestHelper < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    def assert_changes(actuals, expected)
      expects = expected.map(&:data)
      assert_equal(expects, actuals.map(&:data))
    end

    def assert_no_changes(actuals)
      assert_empty(actuals)
    end

    def arrange(stream, events)
      events.each { |event| event_store.publish(event, stream_name: stream) }
    end

    def act(stream, command)
      before = event_store.read.stream(stream).each.to_a
      command_bus.call(command)
      after = event_store.read.stream(stream).each.to_a
      after.reject { |a| before.any? { |b| a.event_id == b.event_id } }
    end

    def handle_event(stream, event)
      before = event_store.read.stream(stream).each.to_a
      event_store.publish(event)
      after = event_store.read.stream(stream).each.to_a
      after.reject { |a| before.any? { |b| a.event_id == b.event_id } }
    end

    def command_bus
      Rails.configuration.command_bus
    end

    def event_store
      Rails.configuration.event_store
    end
  end
end
