# frozen_string_literal: true

require_relative '../lib/processes'
require 'test_helper'

module Processes
  class Test < Infra::ProcessTestHelper
    def before_setup
      super
      Configuration.new.call(command_bus, event_store)
    end
  end
end
