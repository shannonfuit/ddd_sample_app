# frozen_string_literal: true

require_relative 'test_helper'

module JobFulfillment
  class OpenJobOnJobPublishedTest < ProcessTest
    def setup
      @uuid = SecureRandom.uuid
      @starts_on = 1.day.from_now
      @spots = 1
      @contact_uuid = SecureRandom.uuid
      @event_handler = OpenJobOnJobPublished.new(event_store:, command_bus:)
    end

    test 'a job is opened' do
      given([job_published]).each { |event| @event_handler.call(event) }

      assert_command(open_job)
    end

    private

    def job_published
      JobDrafting::JobPublished.new(
        data: {
          job_uuid: @uuid,
          contact_uuid: @contact_uuid,
          shift: { starts_on: @starts_on, ends_on: @starts_on + 1.day },
          spots: 1,
          vacancy: { title: 'MyTitle', description: 'MyDescription', dress_code_requirements: 'Black trousers' },
          wage_per_hour: '12.65',
          work_location: {
            street: 'Korte Akkers',
            house_number: '32',
            city: 'Veendam',
            zip_code: '9644XT'
          }
        }
      )
    end

    def open_job
      JobFulfillment::OpenJob.new(
        job_uuid: @uuid,
        contact_uuid: @contact_uuid,
        starts_on: @starts_on,
        spots: @spots
      )
    end
  end
end
