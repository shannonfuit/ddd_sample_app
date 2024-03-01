# frozen_string_literal: true

module Infra
  class Repository
    def initialize(event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_aggregate(aggregate, stream_name, &)
      repository.with_aggregate(aggregate, stream_name, &)
    end
  end
end
