# frozen_string_literal: true

module JobDrafting
  class Job
    include AggregateRoot

    class JobIsNotPublished < StandardError; end

    def initialize(uuid)
      @uuid = uuid
      @state = :draft
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
