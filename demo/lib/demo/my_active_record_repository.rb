module Demo
  class MyActiveRecordRepository < Infra::Repository
    class Record < ActiveRecord::Base
      self.table_name = "my_active_record_aggregates"
    end
    private_constant :Record

    def initialize(event_store)
      @event_store = event_store
    end

    # preload the complete aggregate,
    # include all nested entities or value objects
    # map the attributes to the aggregate's constructor
    def load(record)
      MyActiveRecordAggregate.new(**record.attributes.symbolize_keys)
    end

    # map the aggregate's attributes to the record's attributes
    # publish the unpublished events
    def store(aggregate, record, stream_name)
      record.update!(aggregate.get_state_for_repository)
      @event_store.publish(
        aggregate.unpublished_events,
        stream_name: stream_name,
        expected_version: :auto
      )
    end

    def with_uuid(uuid, &block)
      record = Record.lock.find_or_initialize_by(uuid: uuid)
      aggregate = load(record)
      block.call(aggregate)
      store(aggregate, record, stream_name(uuid))
    end

    def stream_name(uuid)
      "Demo::MyActiveRecordAggregate$#{uuid}"
    end
  end
end
