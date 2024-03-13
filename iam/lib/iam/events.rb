# frozen_string_literal: true

module Iam
  class CompanyRegistered < Infra::Event
    attribute :company_uuid, Infra::Types::UUID
    attribute :name, Infra::Types::NotEmpty::String
  end

  class ContactRegistered < Infra::Event
    attribute :user_uuid, Infra::Types::UUID
    attribute :first_name, Infra::Types::String
    attribute :last_name, Infra::Types::String
    attribute :email, Infra::Types::String
    attribute :company_uuid, Infra::Types::UUID
  end

  class CandidateRegistered < Infra::Event
    attribute :user_uuid, Infra::Types::UUID
    attribute :first_name, Infra::Types::String
    attribute :last_name, Infra::Types::String
    attribute :email, Infra::Types::String
  end
end
