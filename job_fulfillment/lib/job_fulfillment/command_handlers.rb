# frozen_string_literal: true

module JobFulfillment
  class CommandHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = Jobs.new(event_store)
    end
  end

  class OnCreate < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.create(
          starts_on: command.starts_on,
          spots: command.spots
        )
      end
    end
  end

  class OnApply < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.candidate_applies(
          application_uuid: command.application_uuid,
          candidate_uuid: command.candidate_uuid,
          motivation: command.motivation
        )
      end
    end
  end

  class OnWithdrawApplication < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.withdraw_application(application_uuid: command.application_uuid, candidate_uuid: command.candidate_uuid)
      end
    end
  end

  class OnAcceptApplication < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.accept_application(application_uuid: command.application_uuid)
      end
    end
  end

  class OnRejectApplication < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.reject_application(application_uuid: command.application_uuid)
      end
    end
  end
end
