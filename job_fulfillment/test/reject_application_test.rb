# frozen_string_literal: true

require_relative 'test_helper'

module JobFulfillment
  class RejectApplicationTest < DomainTest
    test 'an application gets rejected' do
      publish_contact_registered
      arrange_candidate_applied

      expected_events = [application_rejected]
      published = act(@stream, reject_application)

      assert_events(published, expected_events)
    end

    test 'no event gets published when a candidate is already rejected' do
      publish_contact_registered
      arrange_candidate_rejected

      published = act(@stream, reject_application)
      assert_no_events(published)
    end

    test 'it raises when an application is not found' do
      publish_contact_registered

      assert_raises(Application::NotFound) do
        act(@stream, reject_application)
      end
    end

    test 'it raises when the application is not pending' do
      publish_contact_registered
      arrange_application_accepted

      assert_raises(Application::NotPending) do
        act(@stream, reject_application)
      end
    end

    test 'it validates the input of the command' do
      publish_contact_registered

      assert_raises(Infra::Command::Invalid) do
        invalid_reject_application
      end
    end

    test 'it raises when contact is not registered' do
      arrange_candidate_applied
      assert_raises(Shared::UserRegistry::UserNotFound) do
        act(@stream, reject_application)
      end
    end

    private

    # commands
    def reject_application
      RejectApplication.new(
        job_uuid: @uuid,
        application_uuid: @application_uuid,
        contact_uuid: @contact_uuid
      )
    end

    def invalid_reject_application
      RejectApplication.new(job_uuid: @uuid)
    end

    # build aggregate
    def arrange_candidate_applied
      arrange_job_opened
      arrange(@stream, [candidate_applied])
    end

    def arrange_application_accepted
      arrange_job_opened
      arrange(@stream, [candidate_applied, application_accepted])
    end

    def arrange_candidate_rejected
      arrange_job_opened
      arrange(@stream, [candidate_applied, application_rejected])
    end

    # events
    def candidate_applied
      CandidateApplied.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid,
          candidate_uuid: @candidate_uuid,
          motivation: 'I want to work here'
        }
      )
    end

    def application_accepted
      ApplicationAccepted.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid,
          contact_uuid: @contact_uuid
        }
      )
    end

    def application_rejected
      ApplicationRejected.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid,
          contact_uuid: @contact_uuid
        }
      )
    end
  end
end
