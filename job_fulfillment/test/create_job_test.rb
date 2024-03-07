# frozen_string_literal: true

require_relative 'test_helper'

module JobFulfillment
  class OpenJobTest < DomainTest
    test 'a job is opened' do
      published = act(@stream, open_job)
      expected_events = [job_opened(spots: @spots, starts_on: @starts_on)]

      assert_events(published, expected_events)
    end

    test 'a job can only be opened once' do
      arrange_job_opened

      assert_raises(Job::AlreadyOpen) { act(@stream, open_job) }
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) { open_invalid_job }
    end

    private

    # commands
    def open_job
      OpenJob.new(
        job_uuid: @uuid,
        contact_uuid: @contact_uuid,
        starts_on: @starts_on,
        spots: @spots
      )
    end

    def open_invalid_job
      OpenJob.new(
        job_uuid: @uuid
      )
    end
  end
end
