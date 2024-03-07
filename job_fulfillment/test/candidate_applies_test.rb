# frozen_string_literal: true

require_relative 'test_helper'

module JobFulfillment
  class CandidateAppliesTest < DomainTest
    def setup
      super
      @motivation = 'I want to work here'
    end

    test 'a candidate applies' do
      arrange_job_opened
      publish_candidate_registered

      published_events = act(@stream, candidate_applies)
      expected_events = [candidate_applied]

      assert_events(published_events, expected_events)
    end

    test 'no event gets published when a candidate already applied' do
      arrange_candidate_applied

      published_events = act(@stream, candidate_applies)

      assert_no_events(published_events)
    end

    test 'it cannot apply if there are no available spots' do
      arrange_another_application_accepted

      assert_raises(Job::NoSpotsAvailable) do
        act(@stream, candidate_applies)
      end
    end

    test 'it cannot apply if application is already accepted' do
      arrange_candidate_accepted

      assert_raises(Application::AlreadySubmitted) do
        act(@stream, candidate_applies)
      end
    end

    test 'it cannot apply if the candidate is not registered' do
      arrange_setup_without_candidate_registered

      assert_raises(Shared::UserRegistry::UserNotFound) do
        act(@stream, candidate_applies)
      end
    end

    test 'it cannot apply if the job has started' do
      arrange_setup_for_job_in_the_past

      assert_raises(Job::HasStarted) do
        act(@stream, candidate_applies)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_candidate_applies
      end
    end

    private

    # commands
    def candidate_applies
      Apply.new(
        job_uuid: @uuid,
        application_uuid: @application_uuid,
        candidate_uuid: @candidate_uuid,
        motivation: @motivation
      )
    end

    def invalid_candidate_applies
      Apply.new(job_uuid: @uuid)
    end

    def arrange_candidate_applied
      arrange_job_opened
      publish_candidate_registered
      arrange(@stream, [candidate_applied])
    end

    def arrange_candidate_accepted
      arrange_job_opened(spots: 2)
      publish_candidate_registered
      arrange(@stream, [candidate_applied, application_accepted])
    end

    def arrange_another_application_accepted
      arrange_job_opened
      publish_candidate_registered
      publish_another_candidate_registered
      arrange(@stream, [another_candidate_applied, another_application_accepted])
    end

    def arrange_setup_without_candidate_registered
      arrange_job_opened
    end

    def arrange_setup_for_job_in_the_past
      publish_candidate_registered
      arrange_job_opened(starts_on: Time.zone.now.yesterday)
    end

    # events
    def candidate_applied
      CandidateApplied.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid,
          candidate_uuid: @candidate_uuid,
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

    def another_candidate_applied
      CandidateApplied.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @another_application_uuid,
          candidate_uuid: @another_candidate_uuid,
          motivation: @motivation
        }
      )
    end

    def another_application_accepted
      ApplicationAccepted.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @another_application_uuid,
          contact_uuid: @contact_uuid
        }
      )
    end
  end
end
