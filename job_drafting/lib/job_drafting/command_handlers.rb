# frozen_string_literal: true

module JobDrafting
  class JobCommandHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = Jobs.new(event_store)
      @user_registry = UserRegistry.new(event_store)
    end

    private

    attr_reader :user_registry
  end

  class ChangeRequestHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = SpotsChangeRequests.new(event_store)
      @user_registry = UserRegistry.new(event_store)
    end

    private

    attr_reader :user_registry
  end

  # Job command handlers
  class OnPublishJob < JobCommandHandler
    def call(command)
      contact = user_registry.find_user!(command.contact_uuid, role: :contact)

      repository.with_job(command.job_uuid) do |job|
        job.set_shift(Shift.from_duration(command.shift_duration))
        job.set_spots(command.spots)
        job.set_vacancy(Vacancy.new(command.title, command.description, command.dress_code_requirements))
        job.set_wage_per_hour(command.wage_per_hour)
        job.set_work_location(WorkLocation.from_address(command.work_location))
        job.publish(contact.uuid)
      end
    end
  end

  class OnChangeSpots < JobCommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.set_spots(command.spots, change_request_uuid: command.change_request_uuid)
      end
    end
  end

  class OnUnpublishJob < JobCommandHandler
    def call(command)
      repository.with_job(command.job_uuid, &:unpublish)
    end
  end

  # Change Request command handlers
  class OnSubmitSpotsChangeRequest < ChangeRequestHandler
    def call(command)
      contact = user_registry.find_user!(command.contact_uuid, role: :contact)
      repository.with_spots_change_request(command.change_request_uuid) do |request|
        request.submit(
          job_uuid: command.job_uuid,
          contact_uuid: contact.uuid,
          requested_spots: command.requested_spots
        )
      end
    end
  end

  class OnApproveSpotsChangeRequest < ChangeRequestHandler
    def call(command)
      repository.with_spots_change_request(command.change_request_uuid, &:approve)
    end
  end

  class OnRejectSpotsChangeRequest < ChangeRequestHandler
    def call(command)
      repository.with_spots_change_request(command.change_request_uuid) do |request|
        request.reject(minimum_required_spots: command.minimum_required_spots)
      end
    end
  end
end
