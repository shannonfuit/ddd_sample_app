# frozen_string_literal: true

module JobFulfillment
  class OpenJob < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :starts_on, Infra::Types::Time
    attribute :spots, Infra::Types::Spots
    attribute :contact_uuid, Infra::Types::UUID # TODO, add also to event
  end

  class ChangeSpots < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :spots, Infra::Types::Spots
    attribute :change_request_uuid, Infra::Types::UUID
  end

  class Apply < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
    attribute :motivation, Infra::Types::NotEmpty::String.optional
    attribute :candidate_uuid, Infra::Types::UUID
  end

  class WithdrawApplication < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
    attribute :candidate_uuid, Infra::Types::UUID
  end

  class AcceptApplication < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
    attribute :contact_uuid, Infra::Types::UUID
  end

  class RejectApplication < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
    attribute :contact_uuid, Infra::Types::UUID
  end
end
