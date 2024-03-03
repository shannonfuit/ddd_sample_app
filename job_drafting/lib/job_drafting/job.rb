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

      apply ShiftSet.new(data: { job_uuid: @uuid, shift: shift.value })
    end

    def set_spots(spots)
      return if @spots == spots

      apply SpotsSet.new(data: { job_uuid: @uuid, spots: })
    end

    def set_vacancy(vacancy)
      return if @vacancy == vacancy

      apply VacancySet.new(data: { job_uuid: @uuid, vacancy: vacancy.value })
    end

    def set_wage_per_hour(wage_per_hour)
      return if @wage_per_hour == wage_per_hour

      apply WagePerHourSet.new(data: { job_uuid: @uuid, wage_per_hour: })
    end

    def set_work_location(work_location)
      return if @work_location == work_location

      apply WorkLocationSet.new(data: { job_uuid: @uuid, work_location: work_location.value })
    end

    def publish
      return if published?
      raise IncompleteDraft unless publishable?

      apply JobPublished.new(
        data: {
          job_uuid: @uuid,
          shift: @shift.value,
          spots: @spots,
          vacancy: @vacancy.value,
          wage_per_hour: @wage_per_hour,
          work_location: @work_location.value
        }
      )
    end

    def unpublish
      return if unpublished?
      raise JobIsNotPublished unless published?

      apply JobUnpublished.new(data: { uuid: @uuid })
    end

    private

    on ShiftSet do |event|
      @shift = Shift.new(**event.data.fetch(:shift))
    end

    on SpotsSet do |event|
      @spots = event.data.fetch(:spots)
    end

    on VacancySet do |event|
      @vacancy = Vacancy.new(**event.data.fetch(:vacancy))
    end

    on WagePerHourSet do |event|
      @wage_per_hour = event.data.fetch(:wage_per_hour)
    end

    on WorkLocationSet do |event|
      @work_location = WorkLocation.new(**event.data.fetch(:work_location))
    end

    on JobPublished do |_event|
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
