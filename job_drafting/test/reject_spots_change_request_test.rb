# frozen_string_literal: true

require_relative 'test_helper'

module JobDrafting
  class RejectSpotsChangedRequestTest < DomainTest
    def setup
      @change_request_uuid = SecureRandom.uuid
      @job_uuid = SecureRandom.uuid
      @contact_uuid = SecureRandom.uuid
      @stream = "JobDrafting::SpotsChangeRequest$#{@change_request_uuid}"
      arrange_change_request_submitted
    end

    test 'a change request is rejected' do
      expected_events = [spots_change_request_rejected]
      published_events = act(@stream, reject_spots_change_request)

      assert_events(expected_events, published_events)
    end

    test 'raises when change request is already rejected' do
      arrange_change_request_rejected

      assert_raises(SpotsChangeRequest::NotPending) do
        act(@stream, reject_spots_change_request)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_reject_change_request
      end
    end

    # commands
    def reject_spots_change_request
      RejectSpotsChangeRequest.new(
        change_request_uuid: @change_request_uuid,
        job_uuid: @job_uuid,
        minimum_required_spots: 2
      )
    end

    def invalid_reject_change_request
      RejectSpotsChangeRequest.new
    end

    # build aggregate
    def arrange_change_request_submitted
      arrange(@stream, [spots_change_request_submitted])
    end

    def arrange_change_request_rejected
      arrange(@stream, [spots_change_request_rejected])
    end

    # events
    def spots_change_request_rejected
      SpotsChangeRequestRejected.new(
        data: {
          change_request_uuid: @change_request_uuid,
          job_uuid: @job_uuid,
          spots_after_change: 2,
          requested_spots: 1
        }
      )
    end

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
