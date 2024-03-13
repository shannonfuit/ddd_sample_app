# frozen_string_literal: true

module JobDrafting
  # UserRegistry as projection
  class UserRegistry < Shared::UserRegistry
    User = Struct.new(:uuid, :role, :company_uuid) do
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
        .when(Iam::ContactRegistered, lambda { |user, event|
          user.uuid = uuid
          user.role = CONTACT_ROLE
          user.company_uuid = event.data.fetch(:company_uuid)
        })
        .run(event_store)
    end

    def add_registered_user(event)
      case event
      when Iam::ContactRegistered
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
