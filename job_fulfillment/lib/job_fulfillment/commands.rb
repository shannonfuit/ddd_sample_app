# frozen_string_literal: true

module JobFulfillment
  class CreateJob < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :starts_on, Infra::Types::Time
    attribute :spots, Infra::Types::Spots
  end

  class Apply < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :candidate_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
    attribute :motivation, Infra::Types::NotEmpty::String.optional
  end

  class WithdrawApplication < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
    attribute :candidate_uuid, Infra::Types::UUID
  end

  class AcceptApplication < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
  end

  class RejectApplication < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
  end
end
