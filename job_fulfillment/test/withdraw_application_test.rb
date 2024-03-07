# frozen_string_literal: true

require_relative 'test_helper'

module JobFulfillment
  class WithdrawApplicationTest < DomainTest
    test 'an application gets withdrawn' do
      arrange_candidate_applied

      expected_events = [application_withdrawn]
      published = act(@stream, withdraw_application)

      assert_events(published, expected_events)
    end

    test 'no event gets published when a candidate is already withdrawn' do
      arrange_candidate_withdrawn

      published = act(@stream, withdraw_application)
      assert_no_events(published)
    end

    test 'it raises when an application is not found' do
      arrange_job_opened
      publish_candidate_registered

      assert_raises(Application::NotFound) do
        act(@stream, withdraw_application)
      end
    end

    test 'it raises when the application is not pending' do
      arrange_application_accepted

      assert_raises(Application::NotPending) do
        act(@stream, withdraw_application)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_withdraw_application
      end
    end

    test 'it requires the candidate to be registered' do
      arrange_setup_without_candidate_registered

      assert_raises(Shared::UserRegistry::UserNotFound) do
        act(@stream, withdraw_application)
      end
    end

    private

    # commands
    def withdraw_application
      WithdrawApplication.new(
        job_uuid: @uuid,
        application_uuid: @application_uuid,
        candidate_uuid: @candidate_uuid
      )
    end

    def invalid_withdraw_application
      WithdrawApplication.new(job_uuid: @uuid)
    end

    # build aggregate
    def arrange_candidate_applied
      arrange_job_opened
      publish_candidate_registered
      arrange(@stream, [candidate_applied])
    end

    def arrange_application_accepted
      arrange_job_opened
      publish_candidate_registered
      arrange(@stream, [candidate_applied, application_accepted])
    end

    def arrange_candidate_withdrawn
      arrange_job_opened
      publish_candidate_registered
      arrange(@stream, [candidate_applied, application_withdrawn])
    end

    def arrange_setup_without_candidate_registered
      arrange_job_opened
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

    def application_withdrawn
      ApplicationWithdrawn.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid,
          candidate_uuid: @candidate_uuid
        }
      )
    end
  end
end
