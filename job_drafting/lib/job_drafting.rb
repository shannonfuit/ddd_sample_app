# frozen_string_literal: true

require_relative 'job_drafting/command_handlers'
require_relative 'job_drafting/commands'
require_relative 'job_drafting/events'
require_relative 'job_drafting/event_handlers'

module JobDrafting
  class Configuration
    def call(event_store, command_bus)
      event_store.subscribe(SendConfrmationMailOnJobPublished, to: [JobPublished])

      command_bus.register(PublishJob, OnPublishJob.new)
      command_bus.register(UnpublishJob, OnUnpublishJob.new)
    end
  end
end
