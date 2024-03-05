# frozen_string_literal: true

module JobDrafting
  class ShiftSetOnJob < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :shift, Shift.type
  end

  class SpotsSetOnJob < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :spots, Infra::Types::Spots
  end

  class VacancySetObJob < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :vacancy, Vacancy.type
  end

  class WagePerHourSetOnJob < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :wage_per_hour, Infra::Types::Money
  end

  class WorkLocationSetOnJob < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :work_location, Infra::Types::Address
  end

  class JobPublished < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :shift, Shift.type
    attribute :spots, Infra::Types::Spots
    attribute :vacancy, Vacancy.type
    attribute :wage_per_hour, Infra::Types::Money
    attribute :work_location, WorkLocation.type
  end

  class JobUnpublished < Infra::Event
  end

  class SpotsChangeRequestSubmitted < Infra::Event
    attribute :spots_change_request_uuid, Infra::Types::UUID
    attribute :job_uuid, Infra::Types::UUID
    attribute :current_spots, Infra::Types::Spots
    attribute :requested_spots, Infra::Types::Spots
  end

  class SpotsChangeRequestAccepted < Infra::Event
    attribute :spots_change_request_uuid, Infra::Types::UUID
    attribute :job_uuid, Infra::Types::UUID
    attribute :spots_before_change, Infra::Types::Spots
    attribute :spots_after_change, Infra::Types::Spots
    attribute :requested_spots, Infra::Types::Spots
  end

  class SpotsChangeRequestRejected < Infra::Event
    attribute :spots_change_request_uuid, Infra::Types::UUID
    attribute :spots_before_change, Infra::Types::Spots
    attribute :spots_after_change, Infra::Types::Spots
    attribute :requested_spots, Infra::Types::Spots
  end
end
