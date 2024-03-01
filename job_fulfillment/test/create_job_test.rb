# frozen_string_literal: true

require 'test_helper'

module JobFulfillment
  class CreateJobTest < Infra::DomainTestHelper
    def setup
      @uuid = SecureRandom.uuid
      @starts_on = Time.zone.now.tomorrow
      @ends_on = Time.zone.now.tomorrow + 1.day
      @number_of_spots = 1
      @stream = "JobFulfillment::Job$#{@uuid}"
    end

    test 'a job is created' do
      create_job = create_job_command
      expected_events = [JobCreated.new(data: job_created_data)]
      published = act(@stream, create_job)

      assert_changes(published, expected_events)
    end

    test 'a job can only be created once' do
      job_created = JobCreated.new(data: job_created_data)
      create_job = create_job_command
      arrange(@stream, [job_created])

      assert_raises(Job::HasAlreadyBeenCreated) do
        act(@stream, create_job)
      end
    end

    test 'it validates the input of the command' do
      expected_errors = { starts_on: ['is missing'], ends_on: ['is missing'], number_of_spots: ['is missing'] }
      error = assert_raises(Infra::Command::InvalidError) do
        create_invalid_job_command
      end

      assert_equal(expected_errors, error.errors)
    end

    private

    def job_created_data
      {
        uuid: @uuid,
        starts_on: @starts_on,
        ends_on: @ends_on,
        number_of_spots: @number_of_spots
      }
    end

    def create_job_command
      CreateJob.new(
        uuid: @uuid,
        starts_on: @starts_on,
        ends_on: @ends_on,
        number_of_spots: @number_of_spots
      )
    end

    def create_invalid_job_command
      CreateJob.new(
        uuid: @uuid
      )
    end
  end
end
