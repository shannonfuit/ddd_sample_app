# frozen_string_literal: true

module JobFulfillment
  class Job
    include AggregateRoot
    class AlreadyOpen < StandardError; end
    class NoSpotsAvailable < StandardError; end
    class NotOpen < StandardError; end
    class HasStarted < StandardError; end

    def initialize(uuid)
      @uuid = uuid
      @state = :new
      @starts_on = nil
      @spots = nil
      @available_spots = nil
      @applications = Application::Collection.new
    end

    def open(starts_on:, spots:)
      raise AlreadyOpen unless new?

      apply JobOpened.new(
        data: {
          job_uuid: @uuid,
          starts_on:,
          spots:
        }
      )
    end

    def change_spots(requested_spots:, change_request_uuid:)
      if @applications.accepted_count <= requested_spots
        apply SpotsChangedAsRequested.new(
          data: {
            job_uuid: @uuid,
            change_request_uuid:,
            spots: requested_spots,
            available_spots: requested_spots - @applications.accepted_count
          }
        )
      else
        apply SpotsChangedToMinimumRequired.new(
          data: {
            job_uuid: @uuid,
            change_request_uuid:,
            spots: @applications.accepted_count,
            available_spots: 0
          }
        )
      end
    end

    def candidate_applies(application_uuid:, candidate_uuid:, motivation:)
      application = @applications.find_by(candidate_uuid:)
      return if application&.pending?

      validate_can_apply

      apply CandidateApplied.new(
        data: {
          job_uuid: @uuid,
          application_uuid:,
          candidate_uuid:,
          motivation:
        }
      )
    end

    def withdraw_application(application_uuid:, candidate_uuid:)
      application = @applications.find_by!(uuid: application_uuid)
      return if application.withdrawn?

      validate_can_witdraw

      apply ApplicationWithdrawn.new(
        data: {
          job_uuid: @uuid,
          application_uuid:,
          candidate_uuid:
        }
      )
    end

    def reject_application(application_uuid:, contact_uuid:)
      application = @applications.find_by!(uuid: application_uuid)
      return if application.rejected?

      validate_can_reject

      apply ApplicationRejected.new(
        data: {
          job_uuid: @uuid,
          application_uuid:,
          contact_uuid:
        }
      )
    end

    def accept_application(application_uuid:, contact_uuid:)
      application = @applications.find_by!(uuid: application_uuid)
      return if application.accepted?

      validate_can_accept

      apply ApplicationAccepted.new(
        data: {
          job_uuid: @uuid,
          application_uuid:,
          contact_uuid:
        }
      )
    end

    private

    on JobOpened do |event|
      @state = :open
      @starts_on = event.data.fetch(:starts_on)
      @spots = event.data.fetch(:spots)
      @available_spots = event.data.fetch(:spots)
    end

    on SpotsChangedAsRequested do |event|
      @spots = event.data.fetch(:spots)
      @available_spots = event.data.fetch(:available_spots)
    end

    on SpotsChangedToMinimumRequired do |event|
      @spots = event.data.fetch(:spots)
      @available_spots = event.data.fetch(:available_spots)
    end

    on CandidateApplied do |event|
      @applications.add_new(
        uuid: event.data.fetch(:application_uuid),
        candidate_uuid: event.data.fetch(:candidate_uuid),
        motivation: event.data.fetch(:motivation)
      )
    end

    on ApplicationWithdrawn do |event|
      application = @applications.find_by(uuid: event.data.fetch(:application_uuid))
      application.withdraw
    end

    on ApplicationRejected do |event|
      application = @applications.find_by(uuid: event.data.fetch(:application_uuid))
      application.reject
    end

    on ApplicationAccepted do |event|
      application = @applications.find_by(uuid: event.data.fetch(:application_uuid))
      application.accept
      @available_spots -= 1
    end

    def validate_can_apply
      validate_job_not_started
      validate_job_open
      validate_available_spots
    end

    def validate_can_witdraw
      validate_job_not_started
    end

    def validate_can_reject
      validate_job_not_started
    end

    def validate_can_accept
      validate_job_not_started
      validate_available_spots
    end

    def validate_job_open
      raise NotOpen unless open?
    end

    def validate_job_not_started
      raise HasStarted unless @starts_on.future?
    end

    def validate_available_spots
      raise NoSpotsAvailable if @spots <= @applications.accepted_count
    end

    def new?
      @state == :new
    end

    def open?
      @state == :open
    end
  end
end
# rubocop: enable Metrics/ClassLength
