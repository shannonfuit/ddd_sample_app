# frozen_string_literal: true

module Infra
  class ReadModelTestHelper < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    attr_reader :event_store

    def before_setup
      super
      @event_store = Infra::EventStore.in_memory
      Customer.configure(event_store)
    end
  end
end
