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
      @current_spots = nil
      @requested_spots = nil
      @minimum_required_spots = nil
    end

    def submit(job_uuid:, current_spots:, requested_spots:)
      puts '##### SpotsChangeRequest: submit'
      raise AlreadySubmitted unless new?

      apply SpotsChangeRequestSubmitted.new(
        data: {
          spots_change_request_uuid: @uuid,
          job_uuid:,
          current_spots:,
          requested_spots:
        }
      )
    end

    def accept
      puts '##### SpotsChangeRequest: accept'
      raise NotPending unless pending?

      apply SpotsChangeRequestAccepted.new(
        data: {
          spots_change_request_uuid: @uuid,
          job_uuid: @job_uuid,
          spots_before_change: @current_spots,
          spots_after_change: @requested_spots,
          requested_spots: @requested_spots
        }
      )
    end

    def reject(minimum_required_spots:)
      puts '##### SpotsChangeRequest: reject'
      raise NotPending unless pending?

      apply SpotsChangeRequestRejected.new(
        data: {
          spots_change_request_uuid: @uuid,
          job_uuid: @job_uuid,
          spots_before_change: @current_spots,
          spots_after_change: minimum_required_spots,
          requested_spots: @requested_spots
        }
      )
    end

    on SpotsChangeRequestSubmitted do |event|
      @state = :pending
      @job_uuid = event.data[:job_uuid]
      @current_spots = event.data[:current_spots]
      @requested_spots = event.data[:requested_spots]
    end

    on SpotsChangeRequestAccepted do |_event|
      @state = :accepted
      @current_spots = @requested_spots
    end

    on SpotsChangeRequestRejected do |event|
      @state = :rejected
      @current_spots = event.data[:minimum_required_spots]
      @minimum_required_spots = event.data[:minimum_required_spots]
    end

    def new?
      @state == :new
    end

    def pending?
      @state == :pending
    end

    def accepted?
      @state == :accepted
    end

    def rejected?
      @state == :rejected
    end
  end
end
