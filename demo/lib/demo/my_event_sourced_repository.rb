module Demo
  class MyEventSourcedRepository < Infra::Repository
    def with_uuid(uuid, &block)
      with_aggregate(MyEventSourcedAggregate.new(uuid), stream_name(uuid), &block)
    end

    private
    attr_reader :repository

    def stream_name(uuid)
      "Demo::MyEventSourcedAggregate$#{uuid}"
    end
  end
end
