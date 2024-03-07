# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'database_cleaner'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # TODO, devise inherited fixtures break with postgresql
    # fixtures :all

    # Setup DatabaseCleaner to use transactions by default
    setup do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end

    # Clean up the database after each test
    teardown do
      DatabaseCleaner.clean
    end
  end
end
