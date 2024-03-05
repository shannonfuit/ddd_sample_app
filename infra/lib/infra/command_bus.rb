# frozen_string_literal: true

module Infra
  class CommandBus < SimpleDelegator
    class FakeCommandBus
      attr_reader :received, :all_received

      def initialize
        @all_received = []
      end

      def call(command)
        @received = command
        @all_received << command
      end

      def clear_all_received
        @all_received = []
        @received = nil
      end
    end

    def self.main
      new(Arkency::CommandBus.new)
    end

    def self.fake
      new(FakeCommandBus.new)
    end
  end
end
