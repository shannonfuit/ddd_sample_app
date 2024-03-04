# frozen_string_literal: true

module JobDrafting
  class SpotsChangeRequests < Infra::Repository
    def with_spots_change_request(uuid, &)
      with_aggregate(SpotsChangeRequest.new(uuid), stream_name(uuid), &)
    end

    private

    attr_reader :repository

    def stream_name(uuid)
      "JobDrafting::SpotsChangeRequest$#{uuid}"
    end
  end
end
