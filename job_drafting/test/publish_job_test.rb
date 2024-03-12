# frozen_string_literal: true

require_relative 'test_helper'

module JobDrafting
  class PublishJobTest < DomainTest
    def setup
      @job_uuid = SecureRandom.uuid
      @stream = "JobDrafting::Job$#{@job_uuid}"

      # ....
    end

    test 'a job can be published' do
      # add_contact_to_registry
      # expected_events = []
      # published_events = act(@stream, publish_job)

      # assert_events(published_events, expected_events)
    end

    test 'a job can only be published once' do
      # add_contact_to_registry
      # arrange_job_published
      # published_events = act(@stream, publish_job)

      # assert_no_events(published_events)
    end

    test 'a job cannot be published if the user is not registered' do
      # assert_raises(Shared::UserRegistry::UserNotFound) { act(@stream, publish_job) }
    end

    # ... add more tests here

    private

    # commands
    def publish_job
      # PublishJob.new(
      #   #...
      # )
    end

    # build aggregate to a specific state
    def arrange_job_published
      # add_contact_to_registry
      # events = [job_published]

      # arrange(@stream, events)
    end

    # events
    def job_published
      # JobPublished.new(
      #   data: {
      #     # ...
      #   }
      # )
    end

    # setup
    def add_contact_to_registry
      event_store.publish(
        Iam::ContactRegistered.new(
          data: {
            user_uuid: @contact_uuid,
            first_name: 'John',
            last_name: 'Doe',
            email: 'john.doe@example.com'
          }
        )
      )
    end
  end
end
