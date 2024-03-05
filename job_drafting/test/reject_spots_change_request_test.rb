# frozen_string_literal: true

require 'test_helper'

module JobDrafting
  class RejectSpotsChangedRequestTest < Infra::DomainTestHelper
    def setup
      @spots_change_request_uuid = SecureRandom.uuid
      @job_uuid = SecureRandom.uuid
      @stream = "JobDrafting::SpotsChangeRequest$#{@spots_change_request_uuid}"
      arrange_change_request_submitted
    end

    test 'a change request is rejected' do
      expected_events = [spots_change_request_rejected_event]
      published_events = act(@stream, reject_spots_change_request_command)
      assert_changes(published_events, expected_events)
    end

    test 'raises when change request is already rejected' do
      arrange_change_request_rejected
      assert_raises(SpotsChangeRequest::NotPending) do
        act(@stream, reject_spots_change_request_command)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_reject_change_request_command
      end
    end

    def reject_spots_change_request_command
      RejectSpotsChangeRequest.new(
        spots_change_request_uuid: @spots_change_request_uuid,
        job_uuid: @job_uuid,
        minimum_required_spots: 2
      )
    end

    def spots_change_request_rejected_event
      SpotsChangeRequestRejected.new(
        data: {
          spots_change_request_uuid: @spots_change_request_uuid,
          job_uuid: @job_uuid,
          spots_before_change: 3,
          spots_after_change: 2,
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

    def arrange_change_request_rejected
      arrange(@stream, [spots_change_request_rejected_event])
    end

    def invalid_reject_change_request_command
      RejectSpotsChangeRequest.new
    end
  end
end
