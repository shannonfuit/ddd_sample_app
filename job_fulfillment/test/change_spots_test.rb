# frozen_string_literal: true

require 'test_helper'

module JobFulfillment
  class ChangeSpotsTest < Infra::DomainTestHelper
    def setup
      @job_uuid = SecureRandom.uuid
      @stream = "JobFulfillment::Job$#{@job_uuid}"
      @candidate_uuid = SecureRandom.uuid
      @another_candidate_uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @another_application_uuid = SecureRandom.uuid
      @motivation = 'I want to work here'

      arrange_setup_for_test
    end

    test 'the number of spots can be changed to the requested amount' do
      published = act(@stream, change_spots_command)
      expected_events = [spots_changed_as_requested_event]

      assert_changes(published, expected_events)
    end

    test 'the number of spots is changed to the minimum required amount' do
      arrange_another_candidate_applied
      published = act(@stream, change_spots_command)
      expected_events = [spots_changed_to_minimum_required_event]

      assert_changes(published, expected_events)
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_change_spots_command
      end
    end

    private

    # commands
    def change_spots_command
      ChangeSpots.new(
        job_uuid: @job_uuid,
        spots: 1
      )
    end

    def invalid_change_spots_command
      ChangeSpots.new(
        job_uuid: @job_uuid
      )
    end

    # events
    def arrange_setup_for_test
      arrange(
        @stream,
        [
          job_created_event,
          candidate_applied_event,
          application_accepted_event
        ]
      )
    end

    def arrange_another_candidate_applied
      arrange(
        @stream,
        [
          another_candidate_applied_event,
          another_application_accepted_event
        ]
      )
    end

    def job_created_event
      JobCreated.new(
        data: {
          job_uuid: @job_uuid,
          starts_on: Time.zone.now.tomorrow,
          ends_on: Time.zone.now.tomorrow + 1.day,
          spots: 3
        }
      )
    end

    def candidate_applied_event
      CandidateApplied.new(
        data:
        {
          job_uuid: @job_uuid,
          application_uuid: @application_uuid,
          candidate_uuid: @candidate_uuid,
          motivation: @motivation
        }
      )
    end

    def another_candidate_applied_event
      CandidateApplied.new(
        data:
        {
          job_uuid: @job_uuid,
          application_uuid: @another_application_uuid,
          candidate_uuid: @another_candidate_uuid,
          motivation: @motivation
        }
      )
    end

    def application_accepted_event
      ApplicationAccepted.new(
        data: {
          job_uuid: @job_uuid,
          application_uuid: @application_uuid
        }
      )
    end

    def another_application_accepted_event
      ApplicationAccepted.new(
        data: {
          job_uuid: @job_uuid,
          application_uuid: @another_application_uuid
        }
      )
    end

    def spots_changed_as_requested_event
      SpotsChangedAsRequested.new(
        data: {
          job_uuid: @job_uuid,
          spots: 1,
          available_spots: 0
        }
      )
    end

    def spots_changed_to_minimum_required_event
      SpotsChangedToMinimumRequired.new(
        data: {
          job_uuid: @job_uuid,
          spots: 2,
          available_spots: 0
        }
      )
    end
  end
end
