# frozen_string_literal: true

module JobDrafting
  class JobDrafted < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :drafted_by, Infra::Types::UUID
    attribute :company_uuid, Infra::Types::UUID
    attribute :shift, Shift.typed_value
    attribute :spots, Infra::Types::Spots
    attribute :vacancy, Vacancy.typed_value
    attribute :wage_per_hour, Infra::Types::Money
    attribute :work_location, WorkLocation.typed_value
  end

  class JobPublished < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :published_by, Infra::Types::UUID
    attribute :shift, Shift.type
    attribute :spots, Infra::Types::Spots
    attribute :vacancy, Vacancy.type
    attribute :wage_per_hour, Infra::Types::Money
    attribute :work_location, WorkLocation.type
  end

  class SpotsChangedOnJob < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :spots, Infra::Types::Spots
    attribute? :change_request_uuid, Infra::Types::UUID.optional
  end

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
