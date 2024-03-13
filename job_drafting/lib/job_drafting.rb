# frozen_string_literal: true

require_relative 'job_drafting/command_handlers'
require_relative 'job_drafting/commands'
require_relative 'job_drafting/events'
require_relative 'job_drafting/event_handlers'

module JobDrafting
  def self.configure(command_bus, event_store)
    # register job commands
    command_bus.register(UnpublishJob, OnUnpublishJob.new)

    # register change request commands
    command_bus.register(SubmitSpotsChangeRequest, OnSubmitSpotsChangeRequest.new)
    command_bus.register(ApproveSpotsChangeRequest, OnApproveSpotsChangeRequest.new)
    command_bus.register(RejectSpotsChangeRequest, OnRejectSpotsChangeRequest.new)

    # registering events
    event_store.subscribe(AddUserOnUserRegistered.new, to: [Iam::ContactRegistered])
  end
end
