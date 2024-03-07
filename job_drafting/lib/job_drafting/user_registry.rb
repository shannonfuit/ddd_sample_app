# frozen_string_literal: true

module JobDrafting
  # UserRegistry as projection
  class UserRegistry < Shared::UserRegistry
    User = Struct.new(:uuid, :role) do
      def nil?
        uuid.blank?
      end

      def present?
        !nil?
      end

      def blank?
        nil?
      end
    end

    def find_by(uuid:)
      RailsEventStore::Projection
        .from_stream(stream_name(uuid))
        .init(-> { User.new })
        .when(Iam::CandidateRegistered, lambda { |user, _event|
          user.uuid = uuid
          user.role = CONTACT_ROLE
        })
        .when(Iam::ContactRegistered, lambda { |user, _event|
          user.uuid = uuid
          user.role = 'contact'
        })
        .run(event_store)
    end

    def add_registered_user(event)
      case event
      when Iam::CandidateRegistered, Iam::ContactRegistered
        Rails.configuration.event_store.link(
          event.event_id,
          stream_name: stream_name(event.data.fetch(:user_uuid))
        )
      else
        raise ArgumentError, "Unknown event type: #{event.class}"
      end
    end

    def stream_name(uuid)
      "JobDrafting::UserRegistry$#{uuid}"
    end
  end
end
