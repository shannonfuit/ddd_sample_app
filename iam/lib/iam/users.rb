# frozen_string_literal: true

module Iam
  class Users < Infra::ActiveRecordRepository
    class Record < ApplicationRecord
      self.table_name = 'iam_users'
    end

    def with_user(uuid, &block)
      record = Record.lock.find_or_initialize_by(uuid:)
      aggregate = load(record)
      block.call(aggregate)
      store(aggregate, uuid, stream_name(uuid)) and return
    end

    def transaction(&)
      Record.transaction(&)
    end

    private

    def load(record)
      User.new(**record.attributes.symbolize_keys)
    end

    def store(aggregate, uuid, stream_name)
      record = Record.lock.find_or_initialize_by(uuid:)
      record.update!(aggregate.state_for_repository)
      @event_store.publish(
        aggregate.unpublished_events,
        stream_name:,
        expected_version: :auto
      )
    end

    def stream_name(uuid)
      "Iam::User$#{uuid}"
    end
  end
end
