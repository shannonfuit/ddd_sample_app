# frozen_string_literal: true

require 'test_helper'
require 'active_support/testing/assertions'

module Infra
  class EventHandlerTest < ActiveSupport::TestCase
    class MyEvent < Event
    end

    class MyEventHandler < EventHandler
      def call(event)
        event
      end
    end

    def setup
      @event = MyEvent.new
      @handler = MyEventHandler.new
      # Rails.configuration.event_store.subscribe(MyEventHandler.new, to: [MyEvent])
      # Rails.configuration.event_store.publish(@event)
    end

    test 'call' do
      assert_equal @event, @handler.call(@event)
    end
  end
end
