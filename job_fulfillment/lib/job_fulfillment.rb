# frozen_string_literal: true

require_relative 'job_fulfillment/command_handlers'
require_relative 'job_fulfillment/commands'
require_relative 'job_fulfillment/events'
require_relative 'job_fulfillment/event_handlers'

module JobFulfillment
  class Configuration
    def call(event_store, command_bus)
      event_store.subscribe(CreateJobOnJobPublished.new, to: [JobDrafting::JobPublished])

      command_bus.register(CreateJob, OnCreate.new)
      command_bus.register(Apply, OnApply.new)
      command_bus.register(WithdrawApplication, OnWithdrawApplication.new)
      command_bus.register(AcceptApplication, OnAcceptApplication.new)
      command_bus.register(RejectApplication, OnRejectApplication.new)
    end
  end
end
