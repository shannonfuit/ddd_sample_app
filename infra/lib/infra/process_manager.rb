# frozen_string_literal: true

module Infra
  class ProcessManager
    class State
      def initialize(**)
        @version = -1
        @event_ids_to_link = []
      end

      def apply(*events)
        events.each do |event|
          apply_event(event)
          @event_ids_to_link << event.event_id
        end
      end

      def apply_event(event)
        raise NotImplementedError
      end

      def load(stream_name, event_store:)
        events = event_store.read.stream(stream_name).forward.to_a
        events.each do |event|
          apply(event)
        end
        @version = events.size - 1
        @event_ids_to_link = []
        self
      end

      def store(stream_name, event_store:)
        event_store.link(
          @event_ids_to_link,
          stream_name:,
          expected_version: @version
        )
        @version += @event_ids_to_link.size
        @event_ids_to_link = []
      end
    end

    def initialize(**attributes)
      @command_bus = attributes[:command_bus] ||= default_command_bus
      @event_store = attributes[:event_bus] ||= default_event_store
    end
    attr_reader :command_bus, :event_store

    def call(_event)
      raise NotImplementedError
    end

    def process_manager_name
      raise NotImplementedError
    end

    def process_manager_identifier
      raise NotImplementedError
    end

    def stream_name
      "#{process_manager_name}$#{process_manager_identifier}"
    end

    def process_event(event, &)
      state = state_class.new
      state.load(stream_name, event_store: @event_store)
      state.apply(event)
      state.store(stream_name, event_store: @event_store)

      yield(state)
    end

    def default_command_bus
      Rails.configuration.command_bus
    end

    def default_event_store
      Rails.configuration.event_store
    end
  end
end
