# frozen_string_literal: true

module Iam
  class User
    include Infra::ActiveRecordAggregateRoot
    AlreadyRegistered = Class.new(StandardError)

    # TODO: value object for name
    def initialize(attributes)
      @uuid = attributes[:uuid]
      @role = attributes[:role] && Role.new(attributes[:role]).value
      @first_name = attributes[:first_name]
      @last_name = attributes[:last_name]
      @email = attributes[:email]
      @state = :new
    end

    def register_as_contact(name:, email:, company_uuid:)
      raise AlreadyRegistered if registered?

      @first_name = name.first_name
      @last_name = name.last_name
      @email = email
      @role = Role.contact.value
      @state = :registered
      @company_uuid = company_uuid

      apply ContactRegistered.new(
        data: {
          user_uuid: @uuid,
          first_name: @first_name,
          last_name: @last_name,
          email: @email,
          company_uuid: @company_uuid
        }
      )
    end

    def register_as_candidate(name:, email:)
      raise AlreadyRegistered if registered?

      @first_name = name.first_name
      @last_name = name.last_name
      @email = email
      @role = Role.candidate.value
      @state = :registered

      apply CandidateRegistered.new(
        data: {
          user_uuid: @uuid,
          first_name: @first_name,
          last_name: @last_name,
          email: @email
        }
      )
    end

    def state_for_repository
      {
        uuid: @uuid,
        role: @role,
        first_name: @first_name,
        last_name: @last_name,
        email: @email,
        state: @state
      }
    end

    private

    def registered?
      @state == :registered
    end
  end
end
