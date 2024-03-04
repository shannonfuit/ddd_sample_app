# frozen_string_literal: true

module Infra
  class ActiveRecordRepository
    def initialize(event_store)
      @event_store = event_store
    end
  end
end
