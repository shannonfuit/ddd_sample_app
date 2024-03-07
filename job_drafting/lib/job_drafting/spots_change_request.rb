# frozen_string_literal: true

module JobDrafting
  class SpotsChangeRequest
    include AggregateRoot

    class AlreadySubmitted < StandardError; end
    class NotPending < StandardError; end

    def initialize(uuid)
      @uuid = uuid
      @state = :new
      @job_uuid = nil
      @requested_spots = nil
      @minimum_required_spots = nil
    end

    def submit(job_uuid:, requested_spots:, contact_uuid:)
      raise AlreadySubmitted unless new?

      apply SpotsChangeRequestSubmitted.new(
        data: {
          change_request_uuid: @uuid,
          contact_uuid:,
          job_uuid:,
          requested_spots:
        }
      )
    end

    def approve
      raise NotPending unless pending?

      apply SpotsChangeRequestApproved.new(
        data: {
          change_request_uuid: @uuid,
          job_uuid: @job_uuid,
          spots_after_change: @requested_spots,
          requested_spots: @requested_spots
        }
      )
    end

    def reject(minimum_required_spots:)
      raise NotPending unless pending?

      apply SpotsChangeRequestRejected.new(
        data: {
          change_request_uuid: @uuid,
          job_uuid: @job_uuid,
          spots_after_change: minimum_required_spots,
          requested_spots: @requested_spots
        }
      )
    end

    on SpotsChangeRequestSubmitted do |event|
      @state = :pending
      @job_uuid = event.data[:job_uuid]
      @contact_uuid = event.data[:contact_uuid]
      @requested_spots = event.data[:requested_spots]
    end

    on SpotsChangeRequestApproved do |_event|
      @state = :approved
    end

    on SpotsChangeRequestRejected do |event|
      @state = :rejected
      @minimum_required_spots = event.data[:minimum_required_spots]
    end

    def new?
      @state == :new
    end

    def pending?
      @state == :pending
    end

    def approved?
      @state == :approved
    end

    def rejected?
      @state == :rejected
    end
  end
end
