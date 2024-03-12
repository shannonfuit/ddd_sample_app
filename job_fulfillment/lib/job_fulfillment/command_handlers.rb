# frozen_string_literal: true

module JobFulfillment
  class CommandHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = Jobs.new(event_store)
      @user_registry = UserRegistry.new
    end

    private

    attr_reader :user_registry
  end

  class OnOpen < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.open(
          starts_on: command.starts_on,
          spots: command.spots
        )
      end
    end
  end

  class OnChangeSpots < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.change_spots(
          requested_spots: command.spots,
          change_request_uuid: command.change_request_uuid
        )
      end
    end
  end
end
