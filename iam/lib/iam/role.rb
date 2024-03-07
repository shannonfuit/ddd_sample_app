# frozen_string_literal: true

module Iam
  ROLES = [
    CONTACT_ROLE = 'contact',
    CANDIDATE_ROLE = 'candidate'
  ].freeze

  Role = Infra::ValueObject.define(:role) do
    def self.contact
      new(CONTACT_ROLE)
    end

    def self.candidate
      new(CANDIDATE_ROLE)
    end

    def initialize(role:)
      raise ArgumentError, "Invalid role: #{role}" unless ROLES.include?(role)

      super
    end

    def value
      role
    end
  end
end
