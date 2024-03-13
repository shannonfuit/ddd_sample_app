# frozen_string_literal: true

module Iam
  class Company
    include AggregateRoot

    AlreadyRegistered = Class.new(StandardError)

    def initialize(uuid)
      @uuid = uuid
      @name = nil
      @state = :new
    end

    def register(name:)
      raise AlreadyRegistered if registered?

      apply CompanyRegistered.new(data: { company_uuid: @uuid, name: })
    end

    private

    on CompanyRegistered do |_event|
      @state = :registered
    end

    def registered?
      @state == :registered
    end
  end
end
