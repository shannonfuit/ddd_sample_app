# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/job_drafting'

module JobDrafting
  class DomainTest < Infra::DomainTestHelper
    def before_setup
      super
      JobDrafting.configure(command_bus, event_store)
    end
  end

  class ProcessTest < Infra::ProcessTestHelper
    def before_setup
      Configuration.new.call(command_bus, event_store)
    end
  end
end
