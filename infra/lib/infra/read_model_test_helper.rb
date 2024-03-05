# frozen_string_literal: true

module Infra
  class ReadModelTestHelper < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    def before_setup
      super
      @event_store = Infra::EventStore.in_memory
      Customer::Configuration.new.call(event_store)
    end

    attr_reader :event_store

    def handle_event(stream, event)
      before = event_store.read.stream(stream).each.to_a
      event_store.publish(event)
      after = event_store.read.stream(stream).each.to_a
      after.reject { |a| before.any? { |b| a.event_id == b.event_id } }
    end
  end
end
