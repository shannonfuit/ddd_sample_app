# frozen_string_literal: true

require 'test_helper'

module JobFulfillment
  class CreateJobOnJobPublishedTest < Infra::DomainTestHelper
    def setup
      @job_uuid = SecureRandom.uuid
      @starts_on = 1.day.from_now
      @spots = 1
      @stream = "JobFulfillment::Job$#{@job_uuid}"
    end

    test 'a job is created' do
      published = handle_event(@stream, job_published_event)
      expected_events = [job_created_event]

      assert_changes(published, expected_events)
    end

    private

    def job_published_event
      JobDrafting::JobPublished.new(
        data: {
          job_uuid: @job_uuid,
          shift: { starts_on: @starts_on, ends_on: @starts_on + 1.day },
          spots: 1,
          vacancy: { title: 'MyTitle', description: 'MyDescription', dress_code_requirements: 'Black trousers' },
          wage_per_hour: '12.65',
          work_location: {
            street: 'Korte Akkers',
            house_number: 32,
            city: 'Veendam',
            zip_code: '9644XT'
          }
        }
      )
    end

    def job_created_event
      JobCreated.new(
        data: {
          job_uuid: @job_uuid,
          starts_on: @starts_on,
          spots: @spots
        }
      )
    end
  end
end
