# frozen_string_literal: true

module Demo
  class MyEventSourcedRepository < Infra::AggregateRootRepository
    def with_uuid(uuid, &)
      with_aggregate(MyEventSourcedAggregate.new(uuid), stream_name(uuid), &)
    end

    private

    attr_reader :repository

    def stream_name(uuid)
      "Demo::MyEventSourcedAggregate$#{uuid}"
    end
  end
end
