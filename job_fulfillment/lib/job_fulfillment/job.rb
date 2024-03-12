# frozen_string_literal: true

module JobFulfillment
  class Job
    include AggregateRoot
    class AlreadyOpen < StandardError; end

    def initialize(uuid)
      @uuid = uuid
      @state = :new
      @starts_on = nil
      @spots = nil
      @available_spots = nil
    end

    def open(starts_on:, spots:)
      raise AlreadyOpen unless new?

      apply JobOpened.new(
        data: {
          job_uuid: @uuid,
          starts_on:,
          spots:
        }
      )
    end

    def change_spots(requested_spots:, change_request_uuid:)
      if @applications.accepted_count <= requested_spots
        apply SpotsChangedAsRequested.new(
          data: {
            job_uuid: @uuid,
            change_request_uuid:,
            spots: requested_spots,
            available_spots: requested_spots - @applications.accepted_count
          }
        )
      else
        apply SpotsChangedToMinimumRequired.new(
          data: {
            job_uuid: @uuid,
            change_request_uuid:,
            spots: @applications.accepted_count,
            available_spots: 0
          }
        )
      end
    end

    private

    on JobOpened do |event|
      @state = :open
      @starts_on = event.data.fetch(:starts_on)
      @spots = event.data.fetch(:spots)
      @available_spots = event.data.fetch(:spots)
    end

    on SpotsChangedAsRequested do |event|
      @spots = event.data.fetch(:spots)
      @available_spots = event.data.fetch(:available_spots)
    end

    on SpotsChangedToMinimumRequired do |event|
      @spots = event.data.fetch(:spots)
      @available_spots = event.data.fetch(:available_spots)
    end

    def new?
      @state == :new
    end

    def open?
      @state == :open
    end
  end
end
# rubocop: enable Metrics/ClassLength
