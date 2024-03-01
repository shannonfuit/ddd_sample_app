module JobFulfillment
  class CommandHandler
    def initialize(event_store)
      @repository = Jobs.new(event_store)
    end

    protected
    attr_reader :repository
  end

  class OnCreate < CommandHandler
    def call(command)
      repository.with_uuid(command.aggregate_id) do |job|
        job.create(
          starts_on: command.starts_on,
          ends_on: command.ends_on,
          number_of_spots: command.number_of_spots
        )
      end
    end
  end

  class OnApply < CommandHandler
    def call(command)
      repository.with_uuid(command.aggregate_id) do |job|
        job.candidate_applies(
          application_uuid: command.application_uuid,
          candidate_uuid:command.candidate_uuid,
          motivation: command.motivation
        )
      end
    end
  end

  class OnWithdrawApplication < CommandHandler
    def call(command)
      repository.with_uuid(command.aggregate_id) do |job|
        job.withdraw_application(application_uuid: command.application_uuid)
      end
    end
  end

  class OnAcceptApplication < CommandHandler
    def call(command)
      repository.with_uuid(command.aggregate_id) do |job|
        job.accept_application(application_uuid: command.application_uuid)
      end
    end
  end

  class OnRejectApplication < CommandHandler
    def call(command)
      repository.with_uuid(command.aggregate_id) do |job|
        job.reject_application(application_uuid: command.application_uuid)
      end
    end
  end
end
