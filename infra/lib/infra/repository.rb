module Infra
  class Repository
    def initialize(event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end
  end
end
