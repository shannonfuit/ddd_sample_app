# frozen_string_literal: true

module JobFulfillment
  class Jobs < Infra::AggregateRootRepository
    def with_job(uuid, &)
      with_aggregate(Job.new(uuid), stream_name(uuid), &)
    end

    private

    attr_reader :repository

    def stream_name(uuid)
      "JobFulfillment::Job$#{uuid}"
    end
  end
end
