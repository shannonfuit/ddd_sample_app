# frozen_string_literal: true

module JobDrafting
  # job commands
  class UnpublishJob < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :contact_uuid, Infra::Types::UUID
  end

  # change request commands
  class SubmitSpotsChangeRequest < Infra::Command
    attribute :change_request_uuid, Infra::Types::UUID
    attribute :job_uuid, Infra::Types::UUID
    attribute :contact_uuid, Infra::Types::UUID
    attribute :requested_spots, Infra::Types::Spots
  end

  class ApproveSpotsChangeRequest < Infra::Command
    attribute :change_request_uuid, Infra::Types::UUID
  end

  class RejectSpotsChangeRequest < Infra::Command
    attribute :change_request_uuid, Infra::Types::UUID
    attribute :minimum_required_spots, Infra::Types::Spots
  end
end
