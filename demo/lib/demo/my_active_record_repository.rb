# frozen_string_literal: true

module Demo
  class MyActiveRecordRepository < Infra::ActiveRecordRepository
    # store your data in a denormalized way so that it is fast for writes
    # Do not specify any belongs_to in on your root
    # because an Aggregate should not share parts with another Aggregate
    # Use nested attributes to store the nested entities
    class Record < ApplicationRecord
      self.table_name = 'my_active_record_aggregates'
    end
    private_constant :Record

    # preload the complete aggregate,
    # include all nested entities or value objects
    # map the attributes to the aggregate's constructor
    # any mapping from record attributes to aggregate attributes would
    # be implemented in the aggregate
    def load(record)
      MyActiveRecordAggregate.new(**record.attributes.symbolize_keys)
    end

    # map the aggregate's attributes to the record's attributes
    # any mapping from aggregate attributes to record attributes would
    # publish the unpublished events
    def store(aggregate, record, stream_name)
      record.update!(aggregate.state_for_repository)
      @event_store.publish(
        aggregate.unpublished_events,
        stream_name:,
        expected_version: :auto
      )
    end

    # TODO: Remove lock and application transaction before the assignment!!
    def with_uuid(uuid, &block)
      record = Record.lock.find_or_initialize_by(uuid:)
      aggregate = load(record)
      block.call(aggregate)
      store(aggregate, record, stream_name(uuid)) and return # so we dont return the eventstore
    end

    def stream_name(uuid)
      "Demo::MyActiveRecordAggregate$#{uuid}"
    end
  end
end
