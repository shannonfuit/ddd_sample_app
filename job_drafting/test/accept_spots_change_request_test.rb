# frozen_string_literal: true

require_relative 'test_helper'

module JobDrafting
  class AcceptSpotsChangedRequestTest < DomainTest
    def setup
      @change_request_uuid = SecureRandom.uuid
      @job_uuid = SecureRandom.uuid
      @contact_uuid = SecureRandom.uuid
      @stream = "JobDrafting::SpotsChangeRequest$#{@change_request_uuid}"
      arrange_change_request_submitted
    end

    test 'a change request is approved' do
      expected_events = [spots_change_request_approved]
      published_events = act(@stream, approve_spots_change_request)

      assert_events(published_events, expected_events)
    end

    test 'raises when change request is already approved' do
      arrange_change_request_approved

      assert_raises(SpotsChangeRequest::NotPending) do
        act(@stream, approve_spots_change_request)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_approve_change_request
      end
    end

    # commands
    def approve_spots_change_request
      ApproveSpotsChangeRequest.new(
        change_request_uuid: @change_request_uuid,
        job_uuid: @job_uuid
      )
    end

    def spots_change_request_approved
      SpotsChangeRequestApproved.new(
        data: {
          change_request_uuid: @change_request_uuid,
          job_uuid: @job_uuid,
          spots_after_change: 1,
          requested_spots: 1
        }
      )
    end

    def invalid_approve_change_request
      ApproveSpotsChangeRequest.new
    end

    # build aggregate
    def arrange_change_request_submitted
      arrange(@stream, [spots_change_request_submitted])
    end

    def arrange_change_request_approved
      arrange(@stream, [spots_change_request_approved])
    end

    # events
    def spots_change_request_submitted
      SpotsChangeRequestSubmitted.new(
        data: {
          change_request_uuid: @change_request_uuid,
          job_uuid: @job_uuid,
          contact_uuid: @contact_uuid,
          requested_spots: 1
        }
      )
    end
  end
end
