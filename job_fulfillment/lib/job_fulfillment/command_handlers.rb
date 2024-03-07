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

  class OnApply < CommandHandler
    def call(command)
      candidate = user_registry.find_user!(command.candidate_uuid, role: :candidate)

      repository.with_job(command.job_uuid) do |job|
        job.candidate_applies(
          application_uuid: command.application_uuid,
          motivation: command.motivation,
          candidate_uuid: candidate.uuid
        )
      end
    end
  end

  class OnWithdrawApplication < CommandHandler
    def call(command)
      candidate = user_registry.find_user!(command.candidate_uuid, role: :candidate)

      repository.with_job(command.job_uuid) do |job|
        job.withdraw_application(
          application_uuid: command.application_uuid,
          candidate_uuid: candidate.uuid
        )
      end
    end
  end

  class OnRejectApplication < CommandHandler
    def call(command)
      contact = user_registry.find_user!(command.contact_uuid, role: :contact)

      repository.with_job(command.job_uuid) do |job|
        job.reject_application(
          application_uuid: command.application_uuid,
          contact_uuid: contact.uuid
        )
      end
    end
  end

  class OnAcceptApplication < CommandHandler
    def call(command)
      contact = user_registry.find_user!(command.contact_uuid, role: :contact)

      repository.with_job(command.job_uuid) do |job|
        job.accept_application(
          application_uuid: command.application_uuid,
          contact_uuid: contact.uuid
        )
      end
    end
  end
end
