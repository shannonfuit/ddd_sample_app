# frozen_string_literal: true

module JobDrafting
  class CommandHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = Jobs.new(event_store)
    end
  end

  class OnPublishJob < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid) do |job|
        job.set_shift(Shift.from_duration(command.shift_duration))
        job.set_spots(command.spots)
        job.set_vacancy(Vacancy.new(command.title, command.description, command.dress_code_requirements))
        job.set_wage_per_hour(command.wage_per_hour)
        job.set_work_location(WorkLocation.from_address(command.work_location))
        job.publish
      end
    end
  end

  class OnUnpublishJob < CommandHandler
    def call(command)
      repository.with_job(command.job_uuid, &:unpublish)
    end
  end
end
