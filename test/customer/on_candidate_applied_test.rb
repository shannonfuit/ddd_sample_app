# frozen_string_literal: true

require 'test_helper'

module Customer
  class OnCandidateAppliedTest < Infra::ReadModelTestHelper
    # include TestHelpers::Integration

    setup do
      @job_uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @candidate_uuid = SecureRandom.uuid
      @motivation = 'I want to work here'

      Job.create(uuid: @job_uuid, status: 'published')
      Candidate.create(uuid: @candidate_uuid, first_name: 'John', last_name: 'Doe')
    end

    test 'adding an application to the job' do
      event_store.publish(candidate_applied_event)
      assert_equal(
        [{
          uuid: @application_uuid,
          status: 'pending',
          motivation: @motivation,
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
      Customer::JobEventHandlers::OnCandidateApplied.new.call(candidate_applied_event)
      Customer::JobEventHandlers::OnCandidateApplied.new.call(candidate_applied_event)

      assert_equal(
        [{
          uuid: @application_uuid,
          status: 'pending',
          motivation: @motivation,
          candidate_uuid: @candidate_uuid,
          candidate_name: 'John Doe'
        }],
        job_applications
      )
    end

    def candidate_applied_event
      JobFulfillment::CandidateApplied.new(
        data:
        {
          job_uuid: @job_uuid,
          application_uuid: @application_uuid,
          candidate_uuid: @candidate_uuid,
          motivation: @motivation
        }
      )
    end
  end
end
