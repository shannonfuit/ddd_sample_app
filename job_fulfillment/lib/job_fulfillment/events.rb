# frozen_string_literal: true

module JobFulfillment
  class JobOpened < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :starts_on, Infra::Types::Time
    attribute :spots, Infra::Types::Spots
  end

  class SpotsChangedAsRequested < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :change_request_uuid, Infra::Types::UUID
    attribute :spots, Infra::Types::Spots
    attribute :available_spots, Infra::Types::Integer
  end

  class SpotsChangedToMinimumRequired < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :change_request_uuid, Infra::Types::UUID
    attribute :spots, Infra::Types::Spots
    attribute :available_spots, Infra::Types::Integer
  end
end
