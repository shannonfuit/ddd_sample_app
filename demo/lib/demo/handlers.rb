# frozen_string_literal: true

module Demo
  class Handler
    def initialize(event_store)
      # @repository = MyEventSourcedRepository.new(event_store)
      @repository = MyActiveRecordRepository.new(event_store)
    end

    private

    attr_reader :repository
  end

  class OnDoSomethingSlow < Handler
    def call(command)
      ActiveRecord::Base.transaction do
        repository.with_uuid(command.aggregate_id, &:do_something_slow)
      end
    end
  end

  class OnDoSomethingFast < Handler
    def call(command)
      ActiveRecord::Base.transaction do
        repository.with_uuid(command.aggregate_id, &:do_something_fast)
      end
    end
  end
end
