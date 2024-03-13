# frozen_string_literal: true

require_relative 'test_helper'

module JobDrafting
  class PublishJobTest < DomainTest
    def setup
      @job_uuid = SecureRandom.uuid
      @stream = "JobDrafting::Job$#{@job_uuid}"

      @company_uuid = SecureRandom.uuid
      @contact_uuid = SecureRandom.uuid
      @shift_duration = { starts_on: 1.day.from_now, ends_on: 1.day.from_now }
      @title = 'Waiting tables at Loetje'
      @description = 'take orders and bring out food'
      @dress_code_requirements = nil
      @wage_per_hour = '12.65'
      @work_location = {
        street: 'Korte Akkers',
        house_number: '32',
        city: 'Veendam',
        zip_code: '9644XT'
      }
    end

    test 'a job is published' do
      contact_registered
      expected_events = [job_drafted, job_published]
      published = act(@stream, publish_job)

      assert_events(published, expected_events)
    end

    test 'a job can only be published once' do
      arrange_job_published

      assert_raises(JobDrafting::Job::AlreadyPublished) { act(@stream, publish_job) }
    end

    test 'a job cannot be published if it is not complete' do
      assert_raises(Infra::Command::Invalid) { act(@stream, invalid_publish_job) }
    end

    test 'a job cannot be published if the user is not registered' do
      assert_raises(Shared::UserRegistry::UserNotFound) { act(@stream, publish_job) }
    end

    private

    # commands
    def publish_job
      PublishJob.new(
        job_uuid: @job_uuid,
        contact_uuid: @contact_uuid,
        title: @title,
        description: @description,
        dress_code_requirements: @dress_code_requirements,
        shift_duration: @shift_duration,
        spots: 1,
        vacancy: { title: @title, description: @description, dress_code_requirements: @dress_code_requirements },
        wage_per_hour: @wage_per_hour,
        work_location: @work_location
      )
    end

    def invalid_publish_job
      PublishJob.new(job_uuid: @job_uuid)
    end

    # build aggregate
    def arrange_job_published
      contact_registered
      events = [job_drafted, job_published]

      arrange(@stream, events)
    end

    def contact_registered
      event_store.publish(
        Iam::ContactRegistered.new(
          data: {
            user_uuid: @contact_uuid,
            first_name: 'John',
            last_name: 'Doe',
            email: 'john.doe@example.com',
            company_uuid: @company_uuid
          }
        )
      )
    end

    # events
    def job_published
      JobPublished.new(
        data: {
          job_uuid: @job_uuid,
          published_by: @contact_uuid,
          shift: { starts_on: @shift_duration[:starts_on], ends_on: @shift_duration[:ends_on] },
          spots: 1,
          vacancy: { title: @title, description: @description, dress_code_requirements: @dress_code_requirements },
          wage_per_hour: @wage_per_hour.to_d,
          work_location: @work_location
        }
      )
    end

    def job_drafted
      JobDrafted.new(
        data: {
          job_uuid: @job_uuid,
          company_uuid: @company_uuid,
          drafted_by: @contact_uuid,
          shift: { starts_on: @shift_duration[:starts_on], ends_on: @shift_duration[:ends_on] },
          spots: 1,
          vacancy: { title: @title, description: @description, dress_code_requirements: @dress_code_requirements },
          wage_per_hour: @wage_per_hour.to_d,
          work_location: @work_location
        }
      )
    end
  end
end
