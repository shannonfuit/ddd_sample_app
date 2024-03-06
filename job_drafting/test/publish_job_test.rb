# frozen_string_literal: true

require_relative 'test_helper'

module JobDrafting
  class PublishJobTest < DomainTest
    def setup
      @job_uuid = SecureRandom.uuid
      @stream = "JobDrafting::Job$#{@job_uuid}"

      @shift_duration = { starts_on: 1.day.from_now, ends_on: 1.day.from_now }
      @title = 'Waiting tables at Loetje'
      @description = 'take orders and bring out food'
      @dress_code_requirements = nil
      @wage_per_hour = '12.65'
      @work_location = {
        street: 'Korte Akkers',
        house_number: 32,
        city: 'Veendam',
        zip_code: '9644XT'
      }
    end

    test 'a job is published' do
      expected_events = [
        shift_set_on_job, spots_set_on_job, vacancy_set_on_job, wage_per_hour_set_on_job, work_location_set_on_job,
        job_published
      ]
      published = act(@stream, publish_job)

      assert_events(published, expected_events)
    end

    test 'a job can only be published once' do
      arrange_job_published
      published = act(@stream, publish_job)

      assert_no_events(published)
    end

    test 'a job cannot be published if it is not complete' do
      assert_raises(Infra::Command::Invalid) { act(@stream, invalid_publish_job) }
    end

    private

    # commands
    def publish_job
      PublishJob.new(
        job_uuid: @job_uuid,
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

    # events
    def arrange_job_published
      events = [
        shift_set_on_job, spots_set_on_job, vacancy_set_on_job,
        wage_per_hour_set_on_job, work_location_set_on_job, job_published
      ]

      arrange(@stream, events)
    end

    def job_published
      JobPublished.new(
        data: {
          job_uuid: @job_uuid,
          shift: { starts_on: @shift_duration[:starts_on], ends_on: @shift_duration[:ends_on] },
          spots: 1,
          vacancy: { title: @title, description: @description, dress_code_requirements: @dress_code_requirements },
          wage_per_hour: @wage_per_hour.to_d,
          work_location: @work_location
        }
      )
    end

    def shift_set_on_job
      ShiftSetOnJob.new(
        data: { job_uuid: @job_uuid,
                shift: { starts_on: @shift_duration[:starts_on], ends_on: @shift_duration[:ends_on] } }
      )
    end

    def spots_set_on_job
      SpotsSetOnJob.new(
        data: { job_uuid: @job_uuid, spots: 1 }
      )
    end

    def vacancy_set_on_job
      VacancySetObJob.new(
        data: { job_uuid: @job_uuid,
                vacancy: { title: @title, description: @description,
                           dress_code_requirements: @dress_code_requirements } }
      )
    end

    def wage_per_hour_set_on_job
      WagePerHourSetOnJob.new(
        data: { job_uuid: @job_uuid, wage_per_hour: @wage_per_hour }
      )
    end

    def work_location_set_on_job
      WorkLocationSetOnJob.new(
        data: { job_uuid: @job_uuid, work_location: @work_location }
      )
    end
  end
end
