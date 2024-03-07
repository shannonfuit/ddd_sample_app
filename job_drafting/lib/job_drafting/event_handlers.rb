# frozen_string_literal: true

module JobDrafting
  class SendConfrmationMailOnJobPublished < Infra::EventHandler
    def call(_event)
      # TODO: Send email to customer
    end
  end

  class AddUserOnUserRegistered < Infra::EventHandler
    def initialize(**args)
      super
      @user_registry = UserRegistry.new(event_store)
    end

    def call(event)
      user_registry.add_registered_user(event)
    end

    private

    attr_reader :user_registry
  end
end
