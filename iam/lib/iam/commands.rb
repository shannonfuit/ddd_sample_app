# frozen_string_literal: true

module Iam
  class RegisterCompany < Infra::Command
    attribute :company_uuid, Infra::Types::UUID
    attribute :name, Infra::Types::NotEmpty::String
  end

  class RegisterAsContact < Infra::Command
    attribute :user_uuid, Infra::Types::UUID
    attribute :company_uuid, Infra::Types::UUID
    attribute :email, Infra::Types::NotEmpty::String
    attribute :name, Infra::Types::Name
    # attribute :company_uuid, Infra::Types::UUID # TODO add
  end

  class RegisterAsCandidate < Infra::Command
    attribute :user_uuid, Infra::Types::UUID
    attribute :email, Infra::Types::NotEmpty::String
    attribute :name, Infra::Types::Name
  end
end
