# frozen_string_literal: true

require 'test_helper'

module JobFulfillment
  class CreateJobTest < Infra::DomainTestHelper
    def setup
      @job_uuid = SecureRandom.uuid
      @starts_on = 1.day.from_now
      @spots = 1
      @stream = "JobFulfillment::Job$#{@job_uuid}"
    end

    test 'a job is created' do
      published = act(@stream, create_job_command)
      expected_events = [job_created_event]

      assert_changes(published, expected_events)
    end

    test 'a job can only be created once' do
      job_created = job_created_event
      create_job = create_job_command
      arrange(@stream, [job_created])

      assert_raises(Job::HasAlreadyBeenCreated) { act(@stream, create_job) }
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) { invalid_job_command }
    end

    private

    def job_created_event
      JobCreated.new(
        data: {
          job_uuid: @job_uuid,
          starts_on: @starts_on,
          spots: @spots
        }
      )
    end

    def create_job_command
      CreateJob.new(
        job_uuid: @job_uuid,
        starts_on: @starts_on,
        spots: @spots
      )
    end

    def invalid_job_command
      CreateJob.new(
        job_uuid: @job_uuid
      )
    end
  end
end
