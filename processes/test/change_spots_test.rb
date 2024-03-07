# frozen_string_literal: true

require_relative 'test_helper'

module Processes
  class ChangeSpotsTest < Test
    def setup
      @job_uuid = SecureRandom.uuid
      @contact_uuid = SecureRandom.uuid
      @change_request_uuid = SecureRandom.uuid
      @stream = "Processes::ChangeSpots$#{@change_request_uuid}"
      @process = ChangeSpots.new(command_bus, event_store)
    end

    test 'approve change_request if spots can be changed like requested' do
      events = [change_request_submitted, spots_changed_as_requested, spots_set_in_job_drafting]
      expected_commands = [change_spots, set_spots, approve_spots_change_request]

      given(events).each { |event| @process.call(event) }

      assert_all_commands(*expected_commands)
    end

    test 'reject_change_request if spots can only be changed to minimum required' do
      events = [change_request_submitted, spots_changed_to_minimum_required, spots_set_in_job_drafting]
      expected_commands = [change_spots, set_spots, reject_spots_change_request]

      given(events).each { |event| @process.call(event) }

      assert_all_commands(*expected_commands)
    end

    def change_request_submitted
      JobDrafting::SpotsChangeRequestSubmitted.new(
        data: {
          change_request_uuid: @change_request_uuid,
          job_uuid: @job_uuid,
          contact_uuid: @contact_uuid,
          requested_spots: 1
        }
      )
    end

    def spots_changed_as_requested
      JobFulfillment::SpotsChangedAsRequested.new(
        data: {
          job_uuid: @job_uuid,
          change_request_uuid: @change_request_uuid,
          available_spots: 1,
          spots: 1
        }
      )
    end

    def spots_changed_to_minimum_required
      JobFulfillment::SpotsChangedToMinimumRequired.new(
        data: {
          job_uuid: @job_uuid,
          change_request_uuid: @change_request_uuid,
          available_spots: 0,
          spots: 2
        }
      )
    end

    def spots_set_in_job_drafting
      JobDrafting::SpotsSetOnJob.new(
        data: {
          job_uuid: @job_uuid,
          change_request_uuid: @change_request_uuid,
          spots: 1
        }
      )
    end

    # commands

    def change_spots
      JobFulfillment::ChangeSpots.new(
        change_request_uuid: @change_request_uuid,
        job_uuid: @job_uuid,
        spots: 1
      )
    end

    def set_spots
      JobDrafting::ChangeSpots.new(
        change_request_uuid: @change_request_uuid,
        job_uuid: @job_uuid,
        spots: 1
      )
    end

    def approve_spots_change_request
      JobDrafting::ApproveSpotsChangeRequest.new(
        job_uuid: @job_uuid,
        change_request_uuid: @change_request_uuid
      )
    end

    def reject_spots_change_request
      JobDrafting::RejectSpotsChangeRequest.new(
        job_uuid: @job_uuid,
        change_request_uuid: @change_request_uuid,
        minimum_required_spots: 2
      )
    end
  end
end
