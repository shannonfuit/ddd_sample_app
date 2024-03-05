# frozen_string_literal: true

module Infra
  class EventStore < SimpleDelegator
    def self.main
      new(
        RailsEventStore::JSONClient.new(
          dispatcher: RubyEventStore::ComposedDispatcher.new(
            RailsEventStore::AfterCommitAsyncDispatcher.new(
              scheduler: RailsEventStore::ActiveJobScheduler.new(serializer: JSON)
            ),
            RubyEventStore::Dispatcher.new
          )
        )
      )
    end

    def self.in_memory
      new(
        RubyEventStore::Client.new(
          repository: RubyEventStore::InMemoryRepository.new
        )
      )
    end
  end
end
