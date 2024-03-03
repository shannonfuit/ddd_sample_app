# frozen_string_literal: true

require 'test_helper'

module Infra
  class CommandTest < ActiveSupport::TestCase
    class MyCommand < Infra::Command
      attribute :uuid, Infra::Types::UUID
      attribute :registered_by, Infra::Types::String

      alias aggregate_id uuid
    end

    def setup
      @uuid = SecureRandom.uuid
    end

    test 'can be initialized with valid arguments' do
      valid_args = { uuid: @uuid, registered_by: 'user' }
      command = MyCommand.new(valid_args)

      assert_equal @uuid, command.uuid
      assert_equal 'user', command.registered_by
      assert_equal @uuid, command.aggregate_id
    end

    test 'raises when initialized with missing attributes' do
      invalid_args = { uuid: @uuid }
      assert_raises(Infra::Command::Invalid) do
        MyCommand.new(invalid_args)
      end
    end

    test 'raises when initialized with a different type' do
      invalid_args = { uuid: @uuid, registered_by: 1 }
      assert_raises(Infra::Command::Invalid) do
        MyCommand.new(invalid_args)
      end
    end

    test 'raises when initialized without attributes' do
      assert_raises(Infra::Command::Invalid) do
        MyCommand.new
      end
    end
  end
end
