# frozen_string_literal: true

module JobDrafting
  class Job
    include AggregateRoot

    class NotPublished < StandardError; end

    def initialize(uuid)
      @uuid = uuid
      @state = :draft
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
  end
end
