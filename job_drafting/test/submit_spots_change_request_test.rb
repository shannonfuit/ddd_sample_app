# frozen_string_literal: true

require_relative 'test_helper'

module JobDrafting
  class SubmitSpotsChangeRequestTest < DomainTest
    def setup
      @change_request_uuid = SecureRandom.uuid
      @job_uuid = SecureRandom.uuid
      @contact_uuid = SecureRandom.uuid
      @stream = "JobDrafting::SpotsChangeRequest$#{@change_request_uuid}"
    end

    test 'a change request is submitted' do
      publish_contact_registered

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

    test 'raises when contact is not registered' do
      assert_raises(Shared::UserRegistry::UserNotFound) do
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
        change_request_uuid: @change_request_uuid,
        job_uuid: @job_uuid,
        contact_uuid: @contact_uuid,
        requested_spots: 1
      )
    end

    def invalid_submit_change_request
      SubmitSpotsChangeRequest.new(
        change_request_uuid: @change_request_uuid,
        job_uuid: @job_uuid,
        requested_spots: 0
      )
    end

    # build aggregate
    def arrange_change_request_submitted
      publish_contact_registered
      arrange(@stream, [change_request_submitted])
    end

    def publish_contact_registered
      event_store.publish(contact_registered)
    end

    # events

    def contact_registered
      Iam::ContactRegistered.new(
        data: {
          user_uuid: @contact_uuid,
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com'
        }
      )
    end

    def change_request_submitted
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
