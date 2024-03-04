# frozen_string_literal: true

module JobFulfillment
  class JobCreated < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :starts_on, Infra::Types::Time
    attribute :spots, Infra::Types::Spots
  end

  class CandidateApplied < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
    attribute :candidate_uuid, Infra::Types::UUID
    attribute :motivation, Infra::Types::NotEmpty::String.optional
  end

  class ApplicationWithdrawn < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
    attribute :candidate_uuid, Infra::Types::UUID
  end

  class ApplicationRejected < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
  end

  class ApplicationAccepted < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :application_uuid, Infra::Types::UUID
  end
end
