# frozen_string_literal: true

require_relative 'test_helper'

module JobFulfillment
  class CandidateAppliesTest < DomainTest
    def setup
      @uuid = SecureRandom.uuid
      @candidate_uuid = SecureRandom.uuid
      @another_candidate_uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @another_application_uuid = SecureRandom.uuid
      @motivation = 'I want to work here'
      @stream = "JobFulfillment::Job$#{@uuid}"

      arrange_setup_for_test
    end

    test 'a candidate applies' do
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
      arrange_another_candidate_accepted

      assert_raises(Job::NoSpotsAvailable) do
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

    # events
    def arrange_setup_for_test
      job_created_data = {
        job_uuid: @uuid,
        starts_on: Time.zone.now.tomorrow,
        ends_on: Time.zone.now.tomorrow + 1.day,
        spots: 1
      }
      arrange(@stream, [JobCreated.new(data: job_created_data)])
    end

    def arrange_candidate_applied
      arrange(@stream, [candidate_applied])
    end

    def arrange_another_candidate_accepted
      arrange(@stream, [another_candidate_applied, another_application_accepted])
    end

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
          application_uuid: @another_application_uuid
        }
      )
    end
  end
end
