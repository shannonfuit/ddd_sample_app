# frozen_string_literal: true

module Demo
  class MyActiveRecordRepository < Infra::ActiveRecordRepository
    # store your data in a denormalized way so that it is fast for writes
    # Do not specify any belongs_to on your root,
    # because an Aggregate should not share parts with another Aggregate
    # Use nested attributes to store the nested entities
    class Record < ApplicationRecord
      self.table_name = 'my_active_record_aggregates'
    end
    private_constant :Record

    # preload the complete aggregate,
    # include all nested entities or value objects
    # map the attributes and pass them to the aggregate's constructor
    # any mapping from record attributes to aggregate attributes would
    # be implemented in the aggregate
    def load(record)
      MyActiveRecordAggregate.new(**record.attributes.symbolize_keys)
    end

    # map the aggregate's attributes to the record's columns,
    # and store in a single commit
    # Also publish the unpublished events
    def store(aggregate, uuid, stream_name)
      record = Record.find_or_initialize_by(uuid:)
      record.update!(aggregate.state_for_repository)
      @event_store.publish(
        aggregate.unpublished_events,
        stream_name:,
        expected_version: :auto
      )
    end

    def with_uuid(uuid, &block)
      record = Record.find_or_initialize_by(uuid:)
      aggregate = load(record)
      block.call(aggregate)
      store(aggregate, uuid, stream_name(uuid)) and return # so we dont return the eventstore
    end

    def stream_name(uuid)
      "Demo::MyActiveRecordAggregate$#{uuid}"
    end

    def transaction(&)
      Record.transaction(&)
    end
  end
end
