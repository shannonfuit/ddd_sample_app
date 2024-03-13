# frozen_string_literal: true

require_relative 'iam/command_handlers'
require_relative 'iam/commands'
require_relative 'iam/events'
# require_relative 'iam/event_handlers'

module Iam
  def self.configure(command_bus, _event_store)
    command_bus.register(RegisterCompany, OnRegisterCompany.new)
    command_bus.register(RegisterAsContact, OnRegisterAsContact.new)
    command_bus.register(RegisterAsCandidate, OnRegisterAsCandidate.new)
  end
end
