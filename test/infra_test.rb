# frozen_string_literal: true

require 'test_helper'

Dir[Rails.root.join('infra/test/*_test.rb')].each { |file| require file }
