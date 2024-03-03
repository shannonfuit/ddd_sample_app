# frozen_string_literal: true

module JobFulfillment
  class Application
    class Collection < Array
      def find_by(**args)
        case args.keys.first
        when :candidate_uuid
          find_by_candidate(args[:candidate_uuid])
        when :uuid
          find_by_uuid(args[:uuid])
        else
          raise ArgumentError, "Unknown search criteria: #{args.keys.first}"
        end
      end

      def find_by_candidate(candidate_uuid)
        find { |app| app.candidate_uuid == candidate_uuid }
      end

      def find_by_uuid(uuid)
        find { |app| app.uuid == uuid }
      end
    end

    attr_reader :candidate_uuid, :uuid

    def initialize(uuid:, candidate_uuid:, motivation:)
      @uuid = uuid
      @candidate_uuid = candidate_uuid
      @motivation = motivation
      @status = :pending
    end

    def withdraw
      @status = :withdrawn
    end

    def reject
      @status = :rejected
    end

    def accept
      @status = :accepted
    end

    def pending?
      @status == :pending
    end

    def withdrawn?
      @status == :withdrawn
    end

    def rejected?
      @status == :rejected
    end

    def accepted?
      @status == :accepted
    end
  end
end
