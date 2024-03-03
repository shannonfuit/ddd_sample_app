# frozen_string_literal: true

require 'active_support/core_ext/hash'

module Infra
  class CommandHandler
    def initialize(**args)
      @event_store = args[:event_store] ||= default_event_store
      @repository ||= nil
    end

    protected

    attr_reader :event_store, :repository

    def default_event_store
      Rails.configuration.event_store
    end
  end
end
