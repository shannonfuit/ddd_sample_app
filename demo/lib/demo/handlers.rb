module Demo
  class Handler
    def initialize(event_store)
      # @repository = MyEventSourcedRepository.new(event_store)
      @repository = MyActiveRecordRepository.new(event_store)
    end
  end

  class OnDoSomethingSlow < Handler
    def call(command)
      ActiveRecord::Base.transaction do
        @repository.with_uuid(command.aggregate_id) do |my_aggregate|
          my_aggregate.do_something_slow
        end
      end
    end
  end

  class OnDoSomethingFast < Handler
    def call(command)
      ActiveRecord::Base.transaction do
        @repository.with_uuid(command.aggregate_id) do |my_aggregate|
          my_aggregate.do_something_fast
        end
      end
    end
  end
end
