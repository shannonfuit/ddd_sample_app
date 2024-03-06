# frozen_string_literal: true

require_relative 'test_helper'

module JobDrafting
  class SubmitSpotsChangeRequestTest < DomainTest
    def setup
      @spots_change_request_uuid = SecureRandom.uuid
      @job_uuid = SecureRandom.uuid
      @stream = "JobDrafting::SpotsChangeRequest$#{@spots_change_request_uuid}"
    end

    test 'a change request is submitted' do
      expected_events = [change_request_submitted]
      published_events = act(@stream, submit_change_request)

      assert_events(published_events, expected_events)
    end

    test 'raises when change request is already submitted' do
      arrange_change_request_submitted

      assert_raises(SpotsChangeRequest::AlreadySubmitted) do
        act(@stream, submit_change_request)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_submit_change_request
      end
    end

    private

    # commands
    def submit_change_request
      SubmitSpotsChangeRequest.new(
        spots_change_request_uuid: @spots_change_request_uuid,
        job_uuid: @job_uuid,
        current_spots: 3,
        requested_spots: 1
      )
    end

    def invalid_submit_change_request
      SubmitSpotsChangeRequest.new(
        spots_change_request_uuid: @spots_change_request_uuid,
        job_uuid: @job_uuid,
        current_spots: 0,
        requested_spots: 0
      )
    end

    # events
    def arrange_change_request_submitted
      arrange(@stream, [change_request_submitted])
    end

    def change_request_submitted
      SpotsChangeRequestSubmitted.new(
        data: {
          spots_change_request_uuid: @spots_change_request_uuid,
          job_uuid: @job_uuid,
          current_spots: 3,
          requested_spots: 1
        }
      )
    end
  end
end
