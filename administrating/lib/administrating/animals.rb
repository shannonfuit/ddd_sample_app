module Administrating
  class Animals
    def initialize(event_store = Rails.configuration.event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_registration_number(registration_number, &block)
      repository.with_aggregate(Animal.new, stream_name(registration_number), &block)
    end

    private
    attr_reader :repository

    def stream_name(registration_number)
      "Administrating::Animal$#{registration_number}"
    end
  end
end
