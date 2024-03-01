# frozen_string_literal: true

require 'test_helper'

module JobFulfillment
  class CandidateAppliesTest < Infra::DomainTestHelper
    def setup
      @uuid = SecureRandom.uuid
      @candidate_uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @motivation = 'I want to work here'
      @stream = "JobFulfillment::Job$#{@uuid}"

      arrange_setup_for_test
    end

    test 'a candidate applies' do
      published = act(@stream, candidate_applies_command)
      expected_events = [candidate_applied_event]

      assert_changes(published, expected_events)
    end

    test 'no event gets published when a candidate already applied' do
      arrange(@stream, [candidate_applied_event])
      published = act(@stream, candidate_applies_command)

      assert_no_changes(published)
    end

    test 'it cannot apply if there are no available spots' do
      # TODO: implement later
    end

    test 'it cannot apply if the application is not pending' do
      # TODO: implement later
    end

    test 'it validates the input of the command' do
      expected_errors = { candidate_uuid: ['is missing'], application_uuid: ['is missing'], motivation: ['is missing'] }
      error = assert_raises(Infra::Command::InvalidError) do
        invalid_candidate_applies_command
      end

      assert_equal(expected_errors, error.errors)
    end

    private

    def candidate_applied_event
      CandidateApplied.new(
        data:
        {
          uuid: @uuid,
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
          uuid: @uuid,
          application_uuid: SecureRandom.uuid,
          candidate_uuid: SecureRandom.uuid,
          motivation: @motivation
        }
      )
    end

    def arrange_setup_for_test
      job_created_data = {
        uuid: @uuid,
        starts_on: Time.zone.now.tomorrow,
        ends_on: Time.zone.now.tomorrow + 1.day,
        number_of_spots: 1
      }
      arrange(@stream, [JobCreated.new(data: job_created_data)])
    end

    def candidate_applies_command
      Apply.new(
        uuid: @uuid,
        application_uuid: @application_uuid,
        candidate_uuid: @candidate_uuid,
        motivation: @motivation
      )
    end

    def invalid_candidate_applies_command
      Apply.new(uuid: @uuid)
    end
  end
end
