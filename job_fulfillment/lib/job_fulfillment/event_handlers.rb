# frozen_string_literal: true

module JobFulfillment
  class CreateJobOnJobPublished < Infra::EventHandler
    def call(event)
      command_bus.call(
        CreateJob.new(
          job_uuid: event.data.fetch(:job_uuid),
          starts_on: event.data.fetch(:shift).fetch(:starts_on),
          spots: event.data.fetch(:spots)
        )
      )
    end
  end
end
