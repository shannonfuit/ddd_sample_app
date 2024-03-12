# frozen_string_literal: true

require_relative 'job_fulfillment/command_handlers'
require_relative 'job_fulfillment/commands'
require_relative 'job_fulfillment/events'
require_relative 'job_fulfillment/event_handlers'

module JobFulfillment
  def self.configure(command_bus, event_store)
    command_bus.register(ChangeSpots, OnChangeSpots.new)
    command_bus.register(OpenJob, OnOpen.new)

    event_store.subscribe(OpenJobOnJobPublished.new, to: [JobDrafting::JobPublished])
    event_store.subscribe(AddUserOnUserRegistered.new, to: [Iam::CandidateRegistered, Iam::ContactRegistered])
  end
end
