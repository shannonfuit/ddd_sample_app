# frozen_string_literal: true

require 'test_helper'

module Customer
  class OnApplicationRejectedTest < Infra::ReadModelTestHelper
    # include TestHelpers::Integration

    setup do
      @job_uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @candidate_uuid = SecureRandom.uuid
      @contact_uuid = SecureRandom.uuid

      Job.create(uuid: @job_uuid, status: 'published', applications: [{ uuid: @application_uuid, status: 'pending' }])
    end

    test 'rejects the application on the job' do
      event_store.publish(application_rejected)
      assert_equal(
        [{
          uuid: @application_uuid,
          status: 'rejected'
        }],
        job_applications
      )
    end

    def job_applications
      Job.find_by(uuid: @job_uuid).applications.map(&:deep_symbolize_keys)
    end

    test 'when duplicated' do
      Customer::JobEventHandlers::OnApplicationRejected.new.call(application_rejected)
      Customer::JobEventHandlers::OnApplicationRejected.new.call(application_rejected)

      assert_equal(
        [{
          uuid: @application_uuid,
          status: 'rejected'
        }],
        job_applications
      )
    end

    def application_rejected
      JobFulfillment::ApplicationRejected.new(
        data:
        {
          job_uuid: @job_uuid,
          application_uuid: @application_uuid,
          contact_uuid: @contact_uuid
        }
      )
    end
  end
end
