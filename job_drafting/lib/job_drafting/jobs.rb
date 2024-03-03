# frozen_string_literal: true

module JobDrafting
  class Jobs < Infra::Repository
    def with_job(uuid, &)
      with_aggregate(Job.new(uuid), stream_name(uuid), &)
    end

    private

    attr_reader :repository

    def stream_name(uuid)
      "JobDrafting::Job$#{uuid}"
    end
  end
end
