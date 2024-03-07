# frozen_string_literal: true

module JobFulfillment
  class Application
    NotFound = Class.new(StandardError)
    NotPending = Class.new(StandardError)
    AlreadySubmitted = Class.new(StandardError)

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

      def find_by!(**args)
        find_by(**args) || raise(NotFound)
      end

      def find_by_candidate(candidate_uuid)
        find { |app| app.candidate_uuid == candidate_uuid }
      end

      def find_by_uuid(uuid)
        find { |app| app.uuid == uuid }
      end

      def add_new(uuid:, candidate_uuid:, motivation:)
        raise AlreadySubmitted if find_by(candidate_uuid:)

        self << Application.new(
          uuid:,
          candidate_uuid:,
          motivation:
        )
      end

      def accepted_count
        select(&:accepted?).count
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
      raise NotPending unless pending?

      @status = :withdrawn
    end

    def reject
      raise NotPending unless pending?

      @status = :rejected
    end

    def accept
      raise NotPending unless pending?

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
