# frozen_string_literal: true

module Customer
  module CandidateEventHandlers
    class EventHandler < Infra::EventHandler; end

    class OnCandidateRegistered < EventHandler
      def call(event)
        return if Candidate.exists?(uuid: event.data.fetch(:user_uuid))

        Candidate.create(
          uuid: event.data.fetch(:user_uuid),
          first_name: event.data.fetch(:first_name),
          last_name: event.data.fetch(:last_name)
        )
      end
    end
  end
end
