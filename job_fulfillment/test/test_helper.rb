# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/job_fulfillment'

module JobFulfillment
  class DomainTest < Infra::DomainTestHelper
    def before_setup
      super
      JobFulfillment.configure(command_bus, event_store)
    end

    # rubocop: disable Metrics/MethodLength
    def setup
      super
      @uuid = SecureRandom.uuid
      @company_uuid = SecureRandom.uuid
      @contact_uuid = SecureRandom.uuid
      @starts_on = 1.day.from_now
      @spots = 1

      @application_uuid = SecureRandom.uuid
      @another_application_uuid = SecureRandom.uuid
      @candidate_uuid = SecureRandom.uuid
      @another_candidate_uuid = SecureRandom.uuid

      @stream = "JobFulfillment::Job$#{@uuid}"
    end
    # rubocop: enable Metrics/MethodLength

    def publish_contact_registered
      event_store.publish(contact_registered)
    end

    def publish_candidate_registered
      event_store.publish(candidate_registered)
    end

    def publish_another_candidate_registered
      event_store.publish(another_candidate_registered)
    end

    def arrange_job_opened(spots: @spots, starts_on: @starts_on)
      arrange(@stream, [job_opened(spots:, starts_on:)])
    end

    # events
    def contact_registered
      Iam::ContactRegistered.new(
        data: {
          user_uuid: @contact_uuid,
          first_name: 'Lara',
          last_name: 'Croft',
          email: 'lara.croft@gmail.com',
          company_uuid: @company_uuid
        }
      )
    end

    def candidate_registered
      Iam::CandidateRegistered.new(
        data: {
          user_uuid: @candidate_uuid,
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@gmail.com'
        }
      )
    end

    def another_candidate_registered
      Iam::CandidateRegistered.new(
        data: {
          user_uuid: @another_candidate_uuid,
          first_name: 'Jane',
          last_name: 'Doe',
          email: 'jane.doe@gmail.com'
        }
      )
    end

    def job_opened(spots:, starts_on:)
      JobOpened.new(
        data: {
          job_uuid: @uuid,
          starts_on:,
          spots:
        }
      )
    end
  end

  class ProcessTest < Infra::ProcessTestHelper
  end
end
