# frozen_string_literal: true

require_relative 'job_drafting/command_handlers'
require_relative 'job_drafting/commands'
require_relative 'job_drafting/events'
require_relative 'job_drafting/event_handlers'

module JobDrafting
  def self.configure(command_bus, event_store)
    # register job commands
    command_bus.register(PublishJob, OnPublishJob.new)
    command_bus.register(UnpublishJob, OnUnpublishJob.new)
    command_bus.register(ChangeSpots, OnChangeSpots.new)

    # register change request commands
    command_bus.register(SubmitSpotsChangeRequest, OnSubmitSpotsChangeRequest.new)
    command_bus.register(AcceptSpotsChangeRequest, OnAcceptSpotsChangeRequest.new)
    command_bus.register(RejectSpotsChangeRequest, OnRejectSpotsChangeRequest.new)

    # registering events
    event_store.subscribe(SendConfrmationMailOnJobPublished, to: [JobPublished])
  end
end
