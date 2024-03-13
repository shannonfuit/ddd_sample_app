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
  class OnUnpublishJob < JobCommandHandler
    def call(command)
      contact = user_registry.find_user!(command.contact_uuid, role: :contact)
      repository.with_job(command.job_uuid) do |job|
        job.unpublish(contact.uuid)
      end
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
