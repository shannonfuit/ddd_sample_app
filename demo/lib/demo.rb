# frozen_string_literal: true

require_relative 'demo/command_handlers'
module Demo
  class Configuration
    def call(_event_store, command_bus)
      command_bus.register(DoSomethingSlow, OnDoSomethingSlow.new)
      command_bus.register(DoSomethingFast, OnDoSomethingFast.new)
    end
  end
end
