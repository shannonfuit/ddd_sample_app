# frozen_string_literal: true

module Administrating
  class Animals < Infra::AggregateRootRepository
    def with_uuid(uuid, &)
      with_aggregate(Animal.new, stream_name(uuid), &)
    end

    private

    attr_reader :repository

    def stream_name(uuid)
      "Administrating::Animal$#{uuid}"
    end
  end
end
