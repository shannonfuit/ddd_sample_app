# frozen_string_literal: true

require 'test_helper'

module Customer
  class OnJobUnpublishedTest < ActiveSupport::TestCase
    # include TestHelpers::Integration

    setup do
      @job_uuid = SecureRandom.uuid
      Job.create(uuid: @job_uuid, status: 'published')
    end

    test 'creating a job that does not exist' do
      Rails.configuration.event_store.publish(job_unpublished_event)
      assert_equal(
        {
          uuid: @job_uuid,
          status: 'unpublished'
        }, job_attributes
      )
    end

    test 'skip when duplicated' do
      Customer::JobEventHandlers::OnJobPublished.new.call(job_unpublished_event)
      Customer::JobEventHandlers::OnJobPublished.new.call(job_unpublished_event)

      assert_equal(1, Job.count)
    end

    def job_attributes
      job = Job.find_by(uuid: @job_uuid)
      job&.attributes&.deep_symbolize_keys&.slice(
        :uuid, :status
      )
    end

    def job_unpublished_event
      JobDrafting::JobUnpublished.new(data: { job_uuid: @job_uuid })
    end
  end
end
