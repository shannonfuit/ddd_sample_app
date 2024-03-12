# frozen_string_literal: true

module Processes
  def self.configure(command_bus, event_store)
    Configuration.new.call(command_bus, event_store)
  end

  class Configuration
    def call(command_bus, event_store)
      enable_change_spots_process(command_bus, event_store)
    end

    def enable_change_spots_process(command_bus, event_store)
      # event_store.subscribe(
      #   ChangeSpots.new(command_bus, event_store), to: [
      #     # .....
      #   ]
      # )
    end
  end
end
