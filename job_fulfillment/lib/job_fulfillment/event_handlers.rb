# frozen_string_literal: true

module JobFulfillment
  class OpenJobOnJobPublished < Infra::EventHandler
    def call(event)
      command_bus.call(
        OpenJob.new(
          job_uuid: event.data.fetch(:job_uuid),
          contact_uuid: event.data.fetch(:published_by),
          starts_on: event.data.fetch(:shift).fetch(:starts_on),
          spots: event.data.fetch(:spots)
        )
      )
    end
  end

  class AddUserOnUserRegistered < Infra::EventHandler
    def initialize(**args)
      super
      @user_registry = UserRegistry.new
    end

    def call(event)
      user_registry.add_registered_user(event)
    end

    private

    attr_reader :user_registry
  end
end
