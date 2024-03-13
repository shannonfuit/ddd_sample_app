# frozen_string_literal: true

module JobDrafting
  class Job
    include AggregateRoot

    IncompleteDraft = Class.new(StandardError)
    NotPublished = Class.new(StandardError)
    AlreadyPublished = Class.new(StandardError)
    ShiftNeedsToBeInTheFuture = Class.new(StandardError)

    def initialize(uuid)
      @uuid = uuid
      @state = :draft
      @shift = nil
      @spots = nil
      @vacancy = nil
      @wage_per_hour = nil
      @work_location = nil
      @company_uuid = nil
    end

    def create_draft(attributes)
      raise AlreadyPublished if published?

      validate_shift_in_future(attributes.fetch(:shift))

      apply JobDrafted.new(
        data: {
          job_uuid: @uuid,
          company_uuid: attributes.fetch(:company_uuid),
          drafted_by: attributes.fetch(:contact_uuid),
          shift: attributes.fetch(:shift).value,
          spots: attributes.fetch(:spots),
          vacancy: attributes.fetch(:vacancy).value,
          wage_per_hour: attributes.fetch(:wage_per_hour),
          work_location: attributes.fetch(:work_location).value
        }
      )
    end

    def publish(contact_uuid)
      return if published?
      raise IncompleteDraft unless publishable?

      apply JobPublished.new(
        data: {
          job_uuid: @uuid,
          published_by: contact_uuid,
          shift: @shift.value,
          spots: @spots,
          vacancy: @vacancy.value,
          wage_per_hour: @wage_per_hour,
          work_location: @work_location.value
        }
      )
    end

    def change_spots(spots, change_request_uuid:)
      raise NotPublished unless published?

      return if @spots == spots

      apply SpotsChangedOnJob.new(data: { job_uuid: @uuid, spots:, change_request_uuid: })
    end

    def unpublish(contact_uuid)
      return if unpublished?
      raise NotPublished unless published?

      apply JobUnpublished.new(
        data: {
          job_uuid: @uuid,
          contact_uuid:
        }
      )
    end

    private

    on JobDrafted do |event|
      @company_uuid = event.data.fetch(:company_uuid)
      @shift = Shift.new(**event.data.fetch(:shift))
      @spots = event.data.fetch(:spots)
      @vacancy = Vacancy.new(**event.data.fetch(:vacancy))
      @wage_per_hour = event.data.fetch(:wage_per_hour)
      @work_location = WorkLocation.new(**event.data.fetch(:work_location))
    end

    on JobPublished do |event|
      @published_by = event.data.fetch(:published_by)
      @state = :published
    end

    on SpotsChangedOnJob do |event|
      @spots = event.data.fetch(:spots)
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

    def validate_shift_in_future(shift)
      raise ShiftNeedsToBeInTheFuture unless shift.future?
    end
  end
end
