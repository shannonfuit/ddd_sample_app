# frozen_string_literal: true

require 'test_helper'

module JobDrafting
  class PublishJobTest < Infra::DomainTestHelper
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
        shift_set_event, spots_set_event, vacancy_set_event, wage_per_hour_set_event, work_location_set_event,
        job_published_event
      ]
      published = act(@stream, publish_job_command)
      assert_changes(published, expected_events)
    end

    test 'a job can only be published once' do
      arrange_job_published
      published = act(@stream, publish_job_command)
      assert_no_changes(published)
    end

    test 'a job cannot be published if it is not complete' do
      assert_raises(Infra::Command::Invalid) { act(@stream, publish_invalid_job_command) }
    end

    private

    def shift_set_event
      ShiftSet.new(
        data: { job_uuid: @job_uuid,
                shift: { starts_on: @shift_duration[:starts_on], ends_on: @shift_duration[:ends_on] } }
      )
    end

    def spots_set_event
      SpotsSet.new(
        data: { job_uuid: @job_uuid, spots: 1 }
      )
    end

    def vacancy_set_event
      VacancySet.new(
        data: { job_uuid: @job_uuid,
                vacancy: { title: @title, description: @description,
                           dress_code_requirements: @dress_code_requirements } }
      )
    end

    def wage_per_hour_set_event
      WagePerHourSet.new(
        data: { job_uuid: @job_uuid, wage_per_hour: @wage_per_hour }
      )
    end

    def work_location_set_event
      WorkLocationSet.new(
        data: { job_uuid: @job_uuid, work_location: @work_location }
      )
    end

    def job_published_event
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

    def publish_job_command
      PublishJob.new(
        job_uuid: @job_uuid,
        title: @title,
        description: @description,
        dress_code_requirements: nil,
        shift_duration: @shift_duration,
        spots: 1,
        wage_per_hour: @wage_per_hour,
        work_location: @work_location
      )
    end

    def arrange_job_published
      events = [shift_set_event, spots_set_event, vacancy_set_event, wage_per_hour_set_event, work_location_set_event,
                job_published_event]

      arrange(@stream, events)
    end

    def publish_invalid_job_command
      PublishJob.new(job_uuid: @job_uuid)
    end
  end
end
