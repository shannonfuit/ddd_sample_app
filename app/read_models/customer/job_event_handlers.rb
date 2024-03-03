# frozen_string_literal: true

module Customer
  module JobEventHandlers
    class EventHandler < Infra::EventHandler
      def update_job(job_uuid, &)
        job = Job.find_by(uuid: job_uuid)
        return unless job

        yield(job)
        job.save
      end

      def change_application(job, application_attributes)
        application = job.applications.find { |app| app['uuid'] == application_attributes[:uuid] }

        if application
          application.merge!(application_attributes)
        else
          job.applications << application_attributes
        end
      end
    end

    class OnJobPublished < EventHandler
      def call(event)
        return if Job.exists?(uuid: event.data.fetch(:job_uuid))

        Job.create(
          status: Job::PUBLISHED,
          uuid: event.data.fetch(:job_uuid),
          shift_starts_on: event.data.fetch(:shift).fetch(:starts_on),
          shift_ends_on: event.data.fetch(:shift).fetch(:ends_on),
          spots: event.data.fetch(:spots),
          vacancy: event.data.fetch(:vacancy),
          work_location: event.data.fetch(:work_location),
          wage_per_hour: event.data.fetch(:wage_per_hour)
        )
      end
    end

    class OnJobUnpublished < EventHandler
      def call(event)
        update_job(event.data.fetch(:job_uuid)) do |job|
          job.status = Job::UNPUBLISHED
        end
      end
    end

    class OnCandidateApplied < EventHandler
      def call(event)
        application_attributes = {
          uuid: event.data.fetch(:application_uuid),
          status: Job::APPLICATION_PENDING,
          motivation: event.data.fetch(:motivation),
          candidate_uuid: event.data.fetch(:candidate_uuid),
          candidate_name: Candidate.find_by(uuid: event.data.fetch(:candidate_uuid))&.name
        }

        update_job(event.data.fetch(:job_uuid)) do |job|
          change_application(job, application_attributes)
        end
      end
    end

    class OnApplicationWithdrawn < EventHandler
      def call(event)
        application_attributes = {
          uuid: event.data.fetch(:application_uuid),
          status: Job::APPLICATION_WITHDRAWN,
          candidate_uuid: event.data.fetch(:candidate_uuid),
          candidate_name: Candidate.find_by(uuid: event.data.fetch(:candidate_uuid))&.name
        }

        update_job(event.data.fetch(:job_uuid)) do |job|
          change_application(job, application_attributes)
        end
      end
    end

    class OnApplicationRejected < EventHandler
      def call(event)
        application_attributes = {
          uuid: event.data.fetch(:application_uuid),
          status: Job::APPLICATION_REJECTED
        }

        update_job(event.data.fetch(:job_uuid)) do |job|
          change_application(job, application_attributes)
        end
      end
    end

    class OnApplicationAccepted < EventHandler
      def call(event)
        application_attributes = {
          uuid: event.data.fetch(:application_uuid),
          status: Job::APPLICATION_ACCEPTED
        }

        update_job(event.data.fetch(:job_uuid)) do |job|
          change_application(job, application_attributes)
        end
      end
    end
  end
end
