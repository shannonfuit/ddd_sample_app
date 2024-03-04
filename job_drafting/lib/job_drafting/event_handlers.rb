# frozen_string_literal: true

module JobDrafting
  class SendConfrmationMailOnJobPublished < Infra::EventHandler
    def call(_event)
      # TODO: Send email to customer
    end
  end
end
