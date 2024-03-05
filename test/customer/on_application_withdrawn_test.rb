# frozen_string_literal: true

require 'test_helper'

module Customer
  class OnApplicationWithdrawnTest < Infra::ReadModelTestHelper
    # include TestHelpers::Integration

    setup do
      @job_uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @candidate_uuid = SecureRandom.uuid

      Job.create(uuid: @job_uuid, status: 'published', applications: [{ uuid: @application_uuid, status: 'pending' }])
      Candidate.create(uuid: @candidate_uuid, first_name: 'John', last_name: 'Doe')
    end

    test 'withdraw an application from the job' do
      event_store.publish(application_withdrawn_event)
      assert_equal(
        [{
          uuid: @application_uuid,
          status: 'withdrawn',
          candidate_uuid: @candidate_uuid,
          candidate_name: 'John Doe'
        }],
        job_applications
      )
    end

    def job_applications
      Job.find_by(uuid: @job_uuid).applications.map(&:deep_symbolize_keys)
    end

    test 'when duplicated' do
      Customer::JobEventHandlers::OnApplicationWithdrawn.new.call(application_withdrawn_event)
      Customer::JobEventHandlers::OnApplicationWithdrawn.new.call(application_withdrawn_event)

      assert_equal(
        [{
          uuid: @application_uuid,
          status: 'withdrawn',
          candidate_uuid: @candidate_uuid,
          candidate_name: 'John Doe'
        }],
        job_applications
      )
    end

    def application_withdrawn_event
      JobFulfillment::ApplicationWithdrawn.new(
        data:
        {
          job_uuid: @job_uuid,
          application_uuid: @application_uuid,
          candidate_uuid: @candidate_uuid
        }
      )
    end
  end
end
