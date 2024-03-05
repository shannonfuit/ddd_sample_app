# frozen_string_literal: true

module Processes
  class ChangeSpots < Infra::ProcessManager
    class State < Infra::ProcessManager::State
      attr_reader :job_uuid, :requested_spots, :change_request_uuid, :changed_to

      def initialize
        super
        @job_uuid = nil
        @change_request_uuid = nil
        @status = :pending
        @requested_spots = nil
        @changed_in_job_fulfillment = false
        @changed_in_job_drafting = false
        @changed_to = nil
      end

      def apply_event(event)
        case event
        when JobDrafting::SpotsChangeRequestSubmitted
          apply_request_submitted(event)
        when JobFulfillment::SpotsChangedAsRequested, JobFulfillment::SpotsChangedToMinimumRequired
          apply_changed_in_job_fulfillment(event)
        when JobDrafting::SpotsSetOnJob
          apply_changed_in_job_drafting(event)
        end
      end

      def request_submitted?
        @change_request_uuid.present?
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

      def processed?
        false # TODO: listen to events accepted and rejected
      end

      private

      def apply_request_submitted(event)
        @job_uuid = event.data.fetch(:job_uuid)
        @change_request_uuid = event.data.fetch(:spots_change_request_uuid)
        @requested_spots = event.data.fetch(:requested_spots)
      end

      def apply_changed_in_job_fulfillment(event)
        @changed_in_job_fulfillment = true
        @changed_to = event.data.fetch(:spots)
      end

      def apply_changed_in_job_drafting(_event)
        @changed_in_job_drafting = true
      end
    end

    # rubocop: disable Metrics/MethodLength
    def call(event)
      process_event(event) do |spots_change|
        return unless spots_change.request_submitted? # spots_change.processed?

        if !spots_change.changed_in_job_fulfillment?
          change_in_job_fulfillment(spots_change)
        elsif !spots_change.changed_in_job_drafting?
          change_in_job_drafting(spots_change)
        elsif spots_change.changed_as_requested?
          accept_change_request(spots_change)
        elsif spots_change.changed_to_minimum_required?
          reject_change_request(spots_change)
        end
      end
    end
    # rubocop: enable Metrics/MethodLength

    private

    def change_in_job_fulfillment(spots_change)
      command_bus.call(
        JobFulfillment::ChangeSpots.new(
          job_uuid: spots_change.job_uuid,
          spots: spots_change.requested_spots
        )
      )
    end

    def change_in_job_drafting(spots_change)
      command_bus.call(
        JobDrafting::SetSpotsOnJob.new(
          job_uuid: spots_change.job_uuid,
          spots: spots_change.requested_spots
        )
      )
    end

    def accept_change_request(spots_change)
      command_bus.call(
        JobDrafting::AcceptSpotsChangeRequest.new(
          spots_change_request_uuid: spots_change.change_request_uuid
        )
      )
    end

    def reject_change_request(spots_change)
      command_bus.call(
        JobDrafting::RejectSpotsChangeRequest.new(
          spots_change_request_uuid: spots_change.change_request_uuid,
          minimum_required_spots: spots_change.changed_to
        )
      )
    end

    # some implementations the base class need.
    def state_class
      State
    end

    def process_manager_name
      'Processes::SpotsChange'
    end

    def process_manager_identifier
      @job_uuid
    end
  end
end
