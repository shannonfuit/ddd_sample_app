require "sidekiq/job"

# TODO, enable sidekiq job
module Infra
  class EventHandler < ActiveJob::Base
    prepend RailsEventStore::AsyncHandler
    # @param event [RubyEventStore::Event]
    # @return [void]
    # @abstract
    # @raise [NotImplementedError] If the method is not implemented
    # @example
    #  def call(event)
    #  # do something with the event
    #  end
    def perform(event)
      event_store.with_metadata(correlation_id: event.metadata[:correlation_id], causation_id: event.event_id) do
        call(event)
      end
    end

    def call
      raise NotImplementedError
    end

    private

    def event_store
      Rails.configuration.event_store
    end

    def command_bus
      Rails.configuration.command_bus
    end
  end
end
