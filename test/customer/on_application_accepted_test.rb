# frozen_string_literal: true

require 'test_helper'

module Customer
  class OnApplicationAcceptedTest < Infra::ReadModelTestHelper
    setup do
      @job_uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @candidate_uuid = SecureRandom.uuid

      Job.create(uuid: @job_uuid, status: 'published', applications: [{ uuid: @application_uuid, status: 'pending' }])
    end

    test 'accepts the application on the job' do
      event_store.publish(application_accepted)
      assert_equal(
        [{ uuid: @application_uuid, status: 'accepted' }],
        job_applications
      )
    end

    test 'when duplicated' do
      Customer::JobEventHandlers::OnApplicationAccepted.new.call(application_accepted)
      Customer::JobEventHandlers::OnApplicationAccepted.new.call(application_accepted)

      assert_equal(
        [{ uuid: @application_uuid, status: 'accepted' }],
        job_applications
      )
    end

    def application_accepted
      JobFulfillment::ApplicationAccepted.new(
        data:
        {
          job_uuid: @job_uuid,
          application_uuid: @application_uuid,
          contact_uuid: SecureRandom.uuid
        }
      )
    end

    def job_applications
      Job.find_by(uuid: @job_uuid).applications.map(&:deep_symbolize_keys)
    end
  end
end
