# frozen_string_literal: true

require 'test_helper'

module Infra
  class CommandTest < ActiveSupport::TestCase
    class MyCommand < Infra::Command
      configure_schema do |config|
        config.required(:uuid).filled(:string)
        config.required(:registered_by).filled(:string)
      end

      alias aggregate_id uuid
    end

    test 'can be initialized with valid arguments' do
      valid_args = { uuid: '123', registered_by: 'user' }
      command = MyCommand.new(valid_args)

      assert_equal '123', command.uuid
      assert_equal 'user', command.registered_by
      assert_equal '123', command.aggregate_id
    end

    test 'raises when initialized with missing attributes' do
      invalid_args = { uuid: '123' }
      error = assert_raises(Infra::Command::InvalidError) do
        MyCommand.new(invalid_args)
      end

      assert_equal({ registered_by: ['is missing'] }, error.errors)
    end

    test 'raises when initialized with a different type' do
      invalid_args = { uuid: '123', registered_by: 1 }
      error = assert_raises(Infra::Command::InvalidError) do
        MyCommand.new(invalid_args)
      end

      assert_equal({ registered_by: ['must be a string'] }, error.errors)
    end

    test 'raises when initialized without attributes' do
      error = assert_raises(Infra::Command::InvalidError) do
        MyCommand.new
      end

      assert_equal('arguments cannot be nil', error.message)
    end

    test 'raises when attributes are not keyword attributes' do
      assert_raises(Infra::Command::InvalidError) do
        MyCommand.new
      end
    end

    test 'raises when initialized with extra attributes' do
      invalid_args = { uuid: '123', registered_by: 'user', extra: 'extra' }
      error = assert_raises(Infra::Command::InvalidError) do
        MyCommand.new(invalid_args)
      end

      assert_equal({ extra: ['is not allowed'] }, error.errors)
    end
  end
end
