# frozen_string_literal: true

module Demo
  class DoSomethingFast < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
    end

    alias aggregate_id uuid
  end
end
