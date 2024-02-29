module Administrating
  class Animals < Infra::Repository
    def with_uuid(uuid, &block)
      with_aggregate(Animal.new, stream_name(uuid), &block)
    end

    private
    attr_reader :repository

    def stream_name(uuid)
      "Administrating::Animal$#{uuid}"
    end
  end
end
