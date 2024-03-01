# frozen_string_literal: true

module JobFulfillment
  class CreateJob < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
      config.required(:starts_on).filled(:time)
      config.required(:ends_on).filled(:time)
      config.required(:number_of_spots).filled(:integer)
    end

    alias aggregate_id uuid
  end

  class Apply < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
      config.required(:candidate_uuid).filled(:string)
      config.required(:application_uuid).filled(:string)
      config.required(:motivation).maybe(:string)
    end

    alias aggregate_id uuid
  end

  class WithdrawApplication < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
      config.required(:application_uuid).filled(:string)
    end

    alias aggregate_id uuid
  end

  class AcceptApplication < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
      config.required(:application_uuid).filled(:string)
    end

    alias aggregate_id uuid
  end

  class RejectApplication < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
      config.required(:application_uuid).filled(:string)
    end

    alias aggregate_id uuid
  end

  class ConfirmApplication < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
      config.required(:application_uuid).filled(:string)
    end

    alias aggregate_id uuid
  end

  class CancelApplication < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
      config.required(:application_uuid).filled(:string)
      config.required(:reason).maybe(:string)
    end

    alias aggregate_id uuid
  end
end
