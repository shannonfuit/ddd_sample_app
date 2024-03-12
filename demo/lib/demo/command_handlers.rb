# frozen_string_literal: true

module Demo
  class CommandHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = MyEventSourcedRepository.new(event_store)
      # @repository = MyActiveRecordRepository.new(event_store)
    end
  end

  class OnDoSomethingSlow < CommandHandler
    def call(command)
      repository.with_uuid(command.uuid, &:do_something_slow)
    end
  end

  class OnDoSomethingFast < CommandHandler
    def call(command)
      repository.with_uuid(command.uuid, &:do_something_fast)
    end
  end
end
