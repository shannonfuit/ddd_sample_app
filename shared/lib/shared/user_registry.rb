# frozen_string_literal: true

module Shared
  # In your Baseclass
  # Define a User class that responds to role, uuid and blank?
  # Define a find_by method that returns an instance of User
  #
  # When the implementation uses the event_store for persistence, define
  # make sure the initializer is calling super with an event_store
  # and define the stream_name method
  class UserRegistry
    InvalidRoleError = Class.new(StandardError)
    UserNotFound = Class.new(StandardError)

    ROLES = [
      CONTACT_ROLE = 'contact',
      CANDIDATE_ROLE = 'candidate'
    ].freeze

    def initialize(event_store = nil)
      @event_store = event_store
    end

    def find_user!(uuid, role: nil)
      role = role.to_s if role.present?
      raise ArgumentError, "supported_roles are: #{ROLES}" if role.present? && !valid_role?(role)

      find_by(uuid:).tap do |user|
        raise UserNotFound if user.blank?
        raise InvalidRoleError, "expected role to be #{role} but got #{user.role}" if role.present? && role != user.role
      end
    end

    def add_registered_user(event)
      raise NotImplementedError
    end

    private

    attr_reader :event_store

    def stream_name(uuid)
      raise NotImplementedError
    end

    def find_by(uuid:)
      raise NotImplementedError, 'should return instance of User with a uuid and a role'
    end

    def valid_role?(role)
      ROLES.include?(role)
    end
  end
end
