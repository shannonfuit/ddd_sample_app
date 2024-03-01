module JobFulfillment
  class Jobs < Infra::Repository
    def with_uuid(uuid, &block)
      with_aggregate(Job.new(uuid), stream_name(uuid), &block)
    end

    private
    attr_reader :repository

    def stream_name(uuid)
      "JobFulfillment::Job$#{uuid}"
    end
  end
end
