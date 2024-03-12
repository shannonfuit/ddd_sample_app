# frozen_string_literal: true

module JobDrafting
  class JobUnpublished < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :contact_uuid, Infra::Types::UUID
  end

  class SpotsChangeRequestSubmitted < Infra::Event
    attribute :change_request_uuid, Infra::Types::UUID
    attribute :job_uuid, Infra::Types::UUID
    attribute :contact_uuid, Infra::Types::UUID
    attribute :requested_spots, Infra::Types::Spots
  end

  class SpotsChangeRequestApproved < Infra::Event
    attribute :change_request_uuid, Infra::Types::UUID
    attribute :job_uuid, Infra::Types::UUID
    attribute :spots_after_change, Infra::Types::Spots
    attribute :requested_spots, Infra::Types::Spots
  end

  class SpotsChangeRequestRejected < Infra::Event
    attribute :change_request_uuid, Infra::Types::UUID
    attribute :spots_after_change, Infra::Types::Spots
    attribute :requested_spots, Infra::Types::Spots
  end
end
