# frozen_string_literal: true

module Iam
  class User
    include Infra::ActiveRecordAggregateRoot
    # TODO: value object for name
    def initialize(attributes)
      @uuid = attributes[:uuid]
      @role = attributes[:role] && Role.new(attributes[:role]).value
      @first_name = attributes[:first_name]
      @last_name = attributes[:last_name]
      @email = attributes[:email]
    end

    def register_as_contact(name:, email:)
      @first_name = name.first_name
      @last_name = name.last_name
      @email = email
      @role = Role.contact.value

      apply ContactRegistered.new(
        data: {
          user_uuid: @uuid,
          first_name: @first_name,
          last_name: @last_name,
          email: @email
        }
      )
    end

    def register_as_candidate(name:, email:)
      @first_name = name.first_name
      @last_name = name.last_name
      @email = email
      @role = Role.candidate.value

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
        email: @email
      }
    end
  end
end
