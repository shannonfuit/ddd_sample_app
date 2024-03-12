# frozen_string_literal: true

module Processes
  class ChangeSpots
    def initialize(command_bus, event_store)
      @command_bus = command_bus
      @event_store = event_store
    end

    def call(event)
      return unless event.data[:change_request_uuid]

      spots_change = build_state(event)

      # implement the use cases below

      # if spots_change.in_some_state?
      #   fire_a_command
      # elsif spots_change.in_another_state?
      #   fire_another_command
      # end
    end

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

    def change_in_job_fulfillment(_spots_change)
      puts '##### ChangeSpots: Change in job fulfillment'
      command_bus.call(
        # call with correct attributes from the spots_change
        JobFulfillment::ChangeSpots.new
      )
    end

    def change_in_job_drafting(_spots_change)
      puts '##### ChangeSpots: Change in job drafting'
      command_bus.call(
        # call with correct attributes from the spots_change
        JobDrafting::ChangeSpots.new
      )
    end

    def approve_request(_spots_change)
      puts '##### ChangeSpots: Accept request'
      command_bus.call(
        # call with correct attributes from the spots_change
        JobDrafting::ApproveSpotsChangeRequest.new
      )
    end

    def reject_request(_spots_change)
      puts '##### ChangeSpots: Reject request'
      command_bus.call(
        # call with correct attributes from the spots_change
        JobDrafting::RejectSpotsChangeRequest.new
      )
    end

    class State
      def initialize
        # specify the inital state.
      end

      # and Metrics/CyclomaticComplexity
      def apply(event)
        case event
        when JobDrafting::SomeEventHappened
          apply_some_event_happened(event)
        when JobFulfillment::SomeOtherEventHappened
          apply_some_other_event_happened(event)
        else
          raise "Don't know how to apply #{event.class}"
        end
      end

      def apply_some_event_happened(event)
        # set the state based on the event
      end

      def apply_some_other_event_happened(event)
        # set the state based on the event
      end

      def in_some_state?
        # @some_attribute.present? || @state == :some_state
      end

      def in_another_state?
        # @some_attribute.present? || @state == :some_state
      end
    end
  end
end
