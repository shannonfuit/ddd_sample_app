# frozen_string_literal: true

require 'test_helper'

module JobFulfillment
  class RejectApplicationTest < Infra::DomainTestHelper
    def setup
      @uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @stream = "JobFulfillment::Job$#{@uuid}"

      arrange_setup_for_test
    end

    test 'an application gets rejected' do
      arrange_candidate_applied
      expected_events = [application_rejected_event]
      published = act(@stream, reject_application_command)

      assert_changes(published, expected_events)
    end

    test 'no event gets published when a candidate is already rejected' do
      arrange_candidate_applied
      arrange(@stream, [application_rejected_event])
      published = act(@stream, reject_application_command)
      assert_no_changes(published)
    end

    test 'it raises when an application is not found' do
      assert_raises(Job::ApplicationNotFound) do
        act(@stream, reject_application_command)
      end
    end

    test 'it raises when the application is not pending' do
      arrange_candidate_accepted
      assert_raises(Job::ApplicationNotPending) do
        act(@stream, reject_application_command)
      end
    end

    test 'it validates the input of the command' do
      expected_errors = { application_uuid: ['is missing'] }
      error = assert_raises(Infra::Command::InvalidError) do
        invalid_reject_application_command
      end

      assert_equal(expected_errors, error.errors)
    end

    private

    def application_rejected_event
      ApplicationRejected.new(
        data:
        {
          uuid: @uuid,
          application_uuid: @application_uuid
        }
      )
    end

    def arrange_candidate_applied
      candidate_applied_event = CandidateApplied.new(
        data:
        {
          uuid: @uuid,
          application_uuid: @application_uuid,
          candidate_uuid: SecureRandom.uuid,
          motivation: @motivation
        }
      )
      arrange(@stream, [candidate_applied_event])
    end

    def arrange_candidate_accepted
      arrange_candidate_applied

      application_accepted_event = ApplicationAccepted.new(
        data:
        {
          uuid: @uuid,
          application_uuid: @application_uuid
        }
      )
      arrange(@stream, [application_accepted_event])
    end

    def arrange_setup_for_test
      job_created_event = JobCreated.new(
        data: {
          uuid: @uuid,
          starts_on: Time.zone.now.tomorrow,
          ends_on: Time.zone.now.tomorrow + 1.day,
          number_of_spots: 1
        }
      )
      arrange(@stream, [job_created_event])
    end

    def reject_application_command
      RejectApplication.new(
        uuid: @uuid,
        application_uuid: @application_uuid
      )
    end

    def invalid_reject_application_command
      RejectApplication.new(uuid: @uuid)
    end
  end
end
