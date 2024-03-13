# frozen_string_literal: true

module Iam
  class Companies < Infra::AggregateRootRepository
    def with_company(uuid, &)
      with_aggregate(Company.new(uuid), stream_name(uuid), &)
    end

    private

    attr_reader :repository

    def stream_name(uuid)
      "Iam::Company$#{uuid}"
    end
  end
end
