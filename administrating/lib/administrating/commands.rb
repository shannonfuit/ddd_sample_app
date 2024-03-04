# frozen_string_literal: true

module Administrating
  class RegisterAnimal < Infra::Command
    # configure_schema do |config|
    #   config.required(:uuid).filled(:string)
    #   config.required(:registered_by).filled(:string)
    # end

    # alias aggregate_id uuid
  end

  class RegisterChip < Infra::Command
    # configure_schema do |config|
    #   config.required(:uuid).filled(:string)
    #   config.required(:number).filled(:integer)
    #   config.required(:registry).filled(:string)
    # end

    # alias aggregate_id uuid
  end

  class ConfirmChipRegistryChange < Infra::Command
    #   configure_schema do |config|
    #     config.required(:uuid).filled(:string)
    #   end

    #   alias aggregate_id uuid
  end
end
