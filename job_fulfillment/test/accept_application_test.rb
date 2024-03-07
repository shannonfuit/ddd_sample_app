# frozen_string_literal: true

require_relative 'test_helper'

module JobFulfillment
  class AcceptApplicationTest < DomainTest
    def setup
      super
      publish_contact_registered
    end

    test 'an application gets accepted' do
      arrange_candidate_applied

      expected_events = [application_accepted]
      published_events = act(@stream, accept_application)

      assert_events(published_events, expected_events)
    end

    test 'no event gets published when a candidate is already accepted' do
      arrange_application_accepted

      published_events = act(@stream, accept_application)

      assert_no_events(published_events)
    end

    test 'cannot accept when the application cannot be found' do
      arrange_job_opened

      assert_raises(Application::NotFound) do
        act(@stream, accept_application)
      end
    end

    test 'it cannot accept if the application is not pending' do
      arrange_application_rejected

      assert_raises(Application::NotPending) do
        act(@stream, accept_application)
      end
    end

    test 'it validates the input of the command' do
      arrange_job_opened

      assert_raises(Infra::Command::Invalid) do
        invalid_accept_application
      end
    end

    private

    # commands
    def accept_application
      AcceptApplication.new(
        job_uuid: @uuid,
        contact_uuid: @contact_uuid,
        application_uuid: @application_uuid
      )
    end

    def invalid_accept_application
      AcceptApplication.new(job_uuid: @uuid)
    end

    # build_aggregate
    def arrange_candidate_applied
      arrange_job_opened
      arrange(@stream, [candidate_applied])
    end

    def arrange_application_accepted
      arrange_job_opened
      arrange(@stream, [candidate_applied, application_accepted])
    end

    def arrange_application_rejected
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
          candidate_uuid: SecureRandom.uuid,
          motivation: @motivation
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
