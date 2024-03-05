# frozen_string_literal: true

module Processes
  class Configuration
    def call(event_store, command_bus)
      enable_change_spots_process(event_store, command_bus)
    end

    def enable_change_spots_process(event_store, _command_bus)
      event_store.subscribe(
        ChangeSpots.new, to: [
          JobDrafting::SpotsChangeRequestSubmitted,
          JobFulfillment::SpotsChangedAsRequested,
          JobFulfillment::SpotsChangedToMinimumRequired,
          JobDrafting::SpotsSetOnJob
        ]
      )
    end
  end
end
