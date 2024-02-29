module Infra
  class Repository
    def initialize(event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_aggregate(aggregate, stream_name, &block)
      repository.with_aggregate(aggregate, stream_name, &block)
    end
  end
end
