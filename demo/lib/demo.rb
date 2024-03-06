# frozen_string_literal: true

require_relative 'demo/command_handlers'
module Demo
  def self.configure(command_bus, _event_store)
    command_bus.register(DoSomethingSlow, OnDoSomethingSlow.new)
    command_bus.register(DoSomethingFast, OnDoSomethingFast.new)
  end
end
