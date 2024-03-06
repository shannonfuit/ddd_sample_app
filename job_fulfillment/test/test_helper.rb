# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/job_fulfillment'

module JobFulfillment
  class DomainTest < Infra::DomainTestHelper
    def before_setup
      super
      JobFulfillment.configure(command_bus, event_store)
    end
  end

  class ProcessTest < Infra::ProcessTestHelper
  end
end
