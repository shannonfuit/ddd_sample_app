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
end
