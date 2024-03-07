# frozen_string_literal: true

module JobFulfillment
  # UserRegistry as read model
  class UserRegistry < Shared::UserRegistry
    class User < ApplicationRecord
      self.table_name = 'job_fulfillment_users'
    end

    def find_by(uuid:)
      User.find_by(uuid:)
    end

    def add_registered_user(event)
      role = case event
             when Iam::CandidateRegistered
               CANDIDATE_ROLE
             when Iam::ContactRegistered
               CONTACT_ROLE
             else
               raise ArgumentError, "Unknown event type: #{event.class}"
             end

      User.create!(uuid: event.data.fetch(:user_uuid), role:)
    end
  end
end
