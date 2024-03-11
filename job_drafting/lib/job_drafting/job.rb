# frozen_string_literal: true

module JobDrafting
  class Job
    include AggregateRoot

    class IncompleteDraft < StandardError; end
    class JobIsNotPublished < StandardError; end
    class ShiftNeedsToBeInTheFuture < StandardError; end

    def initialize(uuid)
      @uuid = uuid
      @state = :draft
      @shift = nil
      @spots = nil
      @vacancy = nil
      @wage_per_hour = nil
      @work_location = nil
    end

    def set_shift(shift)
      return if @shift == shift
      raise ShiftNeedsToBeInTheFuture unless shift.future?

      apply ShiftSetOnJob.new(data: { job_uuid: @uuid, shift: shift.value })
    end

    def set_spots(spots, change_request_uuid: nil)
      return if @spots == spots

      SpotsSetOnJob.new(data: { job_uuid: @uuid, spots: })
      apply SpotsSetOnJob.new(data: { job_uuid: @uuid, spots:, change_request_uuid: })
    end

    def set_vacancy(vacancy)
      return if @vacancy == vacancy

      apply VacancySetOnJob.new(data: { job_uuid: @uuid, vacancy: vacancy.value })
    end

    def set_wage_per_hour(wage_per_hour)
      return if @wage_per_hour == wage_per_hour

      apply WagePerHourSetOnJob.new(data: { job_uuid: @uuid, wage_per_hour: })
    end

    def set_work_location(work_location)
      return if @work_location == work_location

      apply WorkLocationSetOnJob.new(data: { job_uuid: @uuid, work_location: work_location.value })
    end

    def publish(contact_uuid)
      return if published?
      raise IncompleteDraft unless publishable?

      apply JobPublished.new(
        data: {
          job_uuid: @uuid,
          contact_uuid:,
          shift: @shift.value,
          spots: @spots,
          vacancy: @vacancy.value,
          wage_per_hour: @wage_per_hour,
          work_location: @work_location.value
        }
      )
    end

    def unpublish(contact_uuid)
      return if unpublished?
      raise JobIsNotPublished unless published?

      apply JobUnpublished.new(
        data: {
          job_uuid: @uuid,
          contact_uuid:
        }
      )
    end

    private

    on ShiftSetOnJob do |event|
      @shift = Shift.new(**event.data.fetch(:shift))
    end

    on SpotsSetOnJob do |event|
      @spots = event.data.fetch(:spots)
    end

    on VacancySetOnJob do |event|
      @vacancy = Vacancy.new(**event.data.fetch(:vacancy))
    end

    on WagePerHourSetOnJob do |event|
      @wage_per_hour = event.data.fetch(:wage_per_hour)
    end

    on WorkLocationSetOnJob do |event|
      @work_location = WorkLocation.new(**event.data.fetch(:work_location))
    end

    on JobPublished do |event|
      @contact_uuid = event.data.fetch(:contact_uuid)
      @state = :published
    end

    on JobUnpublished do |_event|
      @state = :unpublished
    end

    def published?
      @state == :published
    end

    def unpublished?
      @state == :unpublished
    end

    def publishable?
      @shift && @spots && @vacancy && @wage_per_hour && @work_location
    end
  end
end
