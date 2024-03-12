# frozen_string_literal: true

module Demo
  class DoSomethingFast < Infra::Command
    # not a real uuid in our expirement, for readability
    attribute :uuid, Infra::Types::String
  end
end
