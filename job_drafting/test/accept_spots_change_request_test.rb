# frozen_string_literal: true

require_relative 'test_helper'

module JobDrafting
  class AcceptSpotsChangedRequestTest < DomainTest
    def setup
      @spots_change_request_uuid = SecureRandom.uuid
      @job_uuid = SecureRandom.uuid
      @stream = "JobDrafting::SpotsChangeRequest$#{@spots_change_request_uuid}"
      arrange_change_request_submitted
    end

    test 'a change request is accepted' do
      expected_events = [spots_change_request_accepted]
      published_events = act(@stream, accept_spots_change_request)

      assert_events(published_events, expected_events)
    end

    test 'raises when change request is already accepted' do
      arrange_change_request_accepted

      assert_raises(SpotsChangeRequest::NotPending) do
        act(@stream, accept_spots_change_request)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_accept_change_request
      end
    end

    # commands
    def accept_spots_change_request
      AcceptSpotsChangeRequest.new(
        spots_change_request_uuid: @spots_change_request_uuid,
        job_uuid: @job_uuid
      )
    end

    def spots_change_request_accepted
      SpotsChangeRequestAccepted.new(
        data: {
          spots_change_request_uuid: @spots_change_request_uuid,
          job_uuid: @job_uuid,
          spots_before_change: 3,
          spots_after_change: 1,
          requested_spots: 1
        }
      )
    end

    def invalid_accept_change_request
      AcceptSpotsChangeRequest.new
    end

    # events
    def arrange_change_request_submitted
      arrange(@stream, [spots_change_request_submitted])
    end

    def arrange_change_request_accepted
      arrange(@stream, [spots_change_request_accepted])
    end

    def spots_change_request_submitted
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
