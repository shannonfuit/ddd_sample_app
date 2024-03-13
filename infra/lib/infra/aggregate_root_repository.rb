# frozen_string_literal: true

module Infra
  class AggregateRootRepository
    def initialize(event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_aggregate(aggregate, stream_name, &)
      repository.with_aggregate(aggregate, stream_name, &)
      nil # we don't want to return the last version of the aggregate
    end
  end
end
