# frozen_string_literal: true

module Processes
  class ChangeSpots
    def initialize(command_bus, event_store)
      @command_bus = command_bus
      @event_store = event_store
    end

    # rubocop: disable Metrics/MethodLength
    def call(event)
      return unless event.data[:change_request_uuid]

      spots_change = build_state(event)

      if !spots_change.changed_in_job_fulfillment?
        change_in_job_fulfillment(spots_change)
      elsif !spots_change.changed_in_job_drafting?
        change_in_job_drafting(spots_change)
      elsif spots_change.changed_as_requested?
        approve_request(spots_change)
      elsif spots_change.changed_to_minimum_required?
        reject_request(spots_change)
      end
    end

    # rubocop: enable Metrics/MethodLength
    # TODO: extract to base class
    def build_state(event)
      stream_name = stream_name(event)
      past = event_store.read.stream(stream_name).to_a
      last_stored = past.size - 1
      event_store.link(event.event_id, stream_name:, expected_version: last_stored)
      State.new.tap do |state|
        past.each { |ev| state.apply(ev) }
        state.apply(event)
      end
    rescue RubyEventStore::WrongExpectedEventVersion
      retry
    end

    def stream_name(event)
      "Processes::ChangeSpots$#{event.data.fetch(:change_request_uuid)}"
    end

    private

    attr_reader :command_bus, :event_store

    def change_in_job_fulfillment(spots_change)
      puts '##### ChangeSpots: Change in job fulfillment'
      command_bus.call(
        JobFulfillment::ChangeSpots.new(
          job_uuid: spots_change.job_uuid,
          change_request_uuid: spots_change.request_uuid,
          spots: spots_change.requested_spots
        )
      )
    end

    def change_in_job_drafting(spots_change)
      puts '##### ChangeSpots: Change in job drafting'
      command_bus.call(
        JobDrafting::ChangeSpots.new(
          job_uuid: spots_change.job_uuid,
          change_request_uuid: spots_change.request_uuid,
          spots: spots_change.changed_to
        )
      )
    end

    def approve_request(spots_change)
      puts '##### ChangeSpots: Accept request'
      command_bus.call(
        JobDrafting::ApproveSpotsChangeRequest.new(
          change_request_uuid: spots_change.request_uuid
        )
      )
    end

    def reject_request(spots_change)
      puts '##### ChangeSpots: Reject request'
      command_bus.call(
        JobDrafting::RejectSpotsChangeRequest.new(
          change_request_uuid: spots_change.request_uuid,
          minimum_required_spots: spots_change.changed_to
        )
      )
    end

    class State
      attr_reader :request_uuid, :job_uuid, :requested_spots, :changed_to

      def initialize
        @job_uuid = nil
        @request_uuid = nil
        @requested_spots = nil
        @changed_in_job_fulfillment = false
        @changed_in_job_drafting = false
        @changed_to = nil
      end

      # and Metrics/CyclomaticComplexity
      def apply(event)
        @job_uuid ||= event.data.fetch(:job_uuid)

        case event
        when JobDrafting::SpotsChangeRequestSubmitted
          apply_request_submitted(event)
        when JobFulfillment::SpotsChangedAsRequested, JobFulfillment::SpotsChangedToMinimumRequired
          apply_changed_in_job_fulfillment(event)
        when JobDrafting::SpotsChangedOnJob
          apply_changed_in_job_drafting(event)
        end
      end

      def apply_request_submitted(event)
        @request_uuid = event.data.fetch(:change_request_uuid)
        @requested_spots = event.data.fetch(:requested_spots)
      end

      def apply_changed_in_job_fulfillment(event)
        return unless request_submitted?

        @changed_in_job_fulfillment = true
        @changed_to = event.data.fetch(:spots)
      end

      def apply_changed_in_job_drafting(_event)
        return unless request_submitted?

        @changed_in_job_drafting = true
      end

      def request_submitted?
        @request_uuid.present?
      end

      def changed_in_job_fulfillment?
        @changed_in_job_fulfillment
      end

      def changed_in_job_drafting?
        @changed_in_job_drafting
      end

      def changed_as_requested?
        changed_in_job_fulfillment? && changed_in_job_drafting? && @changed_to == @requested_spots
      end

      def changed_to_minimum_required?
        changed_in_job_fulfillment? && changed_in_job_drafting? && @changed_to != @requested_spots
      end
    end
  end
end
