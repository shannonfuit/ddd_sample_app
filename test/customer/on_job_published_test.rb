# frozen_string_literal: true

require 'test_helper'

module Customer
  class OnJobPublishedTest < Infra::ReadModelTestHelper
    setup do
      @job_uuid = SecureRandom.uuid
      @shift_duration = { starts_on: 1.day.from_now, ends_on: 2.days.from_now }
    end

    test 'creating a job that does not exist' do
      event_store.publish(job_published_event)

      assert_equal(1, Job.count)
      assert_equal(
        {
          uuid: @job_uuid,
          status: 'published',
          spots: 1,
          shift_starts_on: @shift_duration[:starts_on],
          shift_ends_on: @shift_duration[:ends_on],
          wage_per_hour: '10.85'.to_d,
          work_location: {
            street: '123 Main St',
            house_number: '123',
            city: 'Anytown',
            zip_code: '12345'
          },
          vacancy: {
            title: 'Bartender',
            description: 'Serving drinks',
            dress_code_requirements: 'Casual'
          }
        }, job_attributes
      )
    end

    test 'skip when duplicated' do
      Customer::JobEventHandlers::OnJobPublished.new.call(job_published_event)
      Customer::JobEventHandlers::OnJobPublished.new.call(job_published_event)

      assert_equal(1, Job.count)
    end

    def job_attributes
      job = Job.find_by(uuid: @job_uuid)
      job&.attributes&.deep_symbolize_keys&.slice(
        :uuid, :status, :spots, :shift_starts_on, :shift_ends_on, :wage_per_hour, :work_location, :vacancy
      )
    end

    def job_published_event
      JobDrafting::JobPublished.new(
        data: {
          job_uuid: @job_uuid,
          published_by: SecureRandom.uuid,
          shift: { starts_on: @shift_duration[:starts_on], ends_on: @shift_duration[:ends_on] },
          spots: 1,
          vacancy: { title: 'Bartender', description: 'Serving drinks', dress_code_requirements: 'Casual' },
          wage_per_hour: '10.85'.to_d,
          work_location: {
            street: '123 Main St',
            house_number: '123',
            city: 'Anytown',
            zip_code: '12345'
          }
        }
      )
    end
  end
end
