# frozen_string_literal: true

module Demo
  class DoSomethingSlow < Infra::Command
    attribute :uuid, Infra::Types::UUID

    alias aggregate_id uuid
  end
end
