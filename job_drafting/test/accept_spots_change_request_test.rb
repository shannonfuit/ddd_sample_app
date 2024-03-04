# frozen_string_literal: true

require 'test_helper'

module JobDrafting
  class AcceptSpotsChangedRequestTest < Infra::DomainTestHelper
    def setup
      @spots_change_request_uuid = SecureRandom.uuid
      @job_uuid = SecureRandom.uuid
      @stream = "JobDrafting::SpotsChangeRequest$#{@spots_change_request_uuid}"
      arrange_change_request_submitted
    end

    test 'a change request is accepted' do
      expected_events = [spots_change_request_accepted_event]
      published = act(@stream, accept_spots_change_request_command)
      assert_changes(published, expected_events)
    end

    test 'raises when change request is already accepted' do
      arrange_change_request_accepted
      assert_raises(SpotsChangeRequest::NotPending) do
        act(@stream, accept_spots_change_request_command)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_accept_change_request_command
      end
    end

    def accept_spots_change_request_command
      AcceptSpotsChangeRequest.new(
        spots_change_request_uuid: @spots_change_request_uuid,
        job_uuid: @job_uuid
      )
    end

    def spots_change_request_accepted_event
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

    def spots_change_request_submitted_event
      SpotsChangeRequestSubmitted.new(
        data: {
          spots_change_request_uuid: @spots_change_request_uuid,
          job_uuid: @job_uuid,
          current_spots: 3,
          requested_spots: 1
        }
      )
    end

    def arrange_change_request_submitted
      arrange(@stream, [spots_change_request_submitted_event])
    end

    def arrange_change_request_accepted
      arrange(@stream, [spots_change_request_accepted_event])
    end

    def invalid_accept_change_request_command
      AcceptSpotsChangeRequest.new
    end
  end
end
