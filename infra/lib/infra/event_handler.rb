# frozen_string_literal: true

require 'sidekiq/job'

module Infra
  class EventHandler < ApplicationJob
    prepend RailsEventStore::AsyncHandler

    def call(_event)
      raise NotImplementedError
    end

    def perform(event)
      event_store.with_metadata(correlation_id: event.metadata[:correlation_id], causation_id: event.event_id) do
        call(event)
      end
    end

    # TODO: define a better solution for this
    def command_bus
      arguments&.first&.dig(:command_bus) || Rails.configuration.command_bus
    end

    def event_store
      arguments&.first&.dig(:event_store) || Rails.configuration.event_store
    end
  end
end
