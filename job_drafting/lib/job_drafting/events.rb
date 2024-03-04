# frozen_string_literal: true

module JobDrafting
  class ShiftSet < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :shift, Shift.type
  end

  class SpotsSet < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :spots, Infra::Types::Spots
  end

  class VacancySet < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :vacancy, Vacancy.type
  end

  class WagePerHourSet < Infra::Event
    attribute :job_uuid, Infra::Types::UUID
    attribute :wage_per_hour, Infra::Types::Money
  end

  class WorkLocationSet < Infra::Event
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
end
