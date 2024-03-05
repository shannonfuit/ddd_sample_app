# frozen_string_literal: true

module JobFulfillment
  class Job
    include AggregateRoot
    class HasAlreadyBeenCreated < StandardError; end
    class HasAlreadApplied < StandardError; end
    class ApplicationNotFound < StandardError; end
    class ApplicationNotPending < StandardError; end

    def initialize(uuid)
      @uuid = uuid
      @state = :new
      @starts_on = nil
      @spots = nil
      @available_spots = nil
      @applications = Application::Collection.new
    end

    def create(starts_on:, spots:)
      raise HasAlreadyBeenCreated if @state == :created

      apply JobCreated.new(
        data: {
          job_uuid: @uuid,
          starts_on:,
          spots:
        }
      )
    end

    def change_spots(requested_spots:)
      if @applications.accepted_count <= requested_spots
        apply SpotsChangedAsRequested.new(
          data: {
            job_uuid: @uuid,
            spots: requested_spots,
            available_spots: requested_spots - @applications.accepted_count
          }
        )
      else
        apply SpotsChangedToMinimumRequired.new(
          data: {
            job_uuid: @uuid,
            spots: @applications.accepted_count,
            available_spots: 0
          }
        )
      end
    end

    def candidate_applies(application_uuid:, candidate_uuid:, motivation:)
      application = @applications.find_by(candidate_uuid:)
      return if application&.pending?

      validate_can_apply(application)

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
      application = @applications.find_by(uuid: application_uuid)
      return if application&.withdrawn?

      validate_can_witdraw(application)

      apply ApplicationWithdrawn.new(
        data: {
          job_uuid: @uuid,
          application_uuid:,
          candidate_uuid:
        }
      )
    end

    def accept_application(application_uuid:)
      application = @applications.find_by(uuid: application_uuid)
      return if application&.accepted?

      validate_can_accept(application)

      apply ApplicationAccepted.new(
        data: {
          job_uuid: @uuid,
          application_uuid:
        }
      )
    end

    def reject_application(application_uuid:)
      application = @applications.find_by(uuid: application_uuid)
      return if application&.rejected?

      validate_can_reject(application)

      apply ApplicationRejected.new(
        data: {
          job_uuid: @uuid,
          application_uuid:
        }
      )
    end

    private

    on JobCreated do |event|
      @state = :created
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
      @applications << Application.new(
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
      @available_spots = - 1
    end

    def validate_can_apply(application)
      validate_job_open
      validate_available_spots
      raise CannotReapply if application.present? && !application.pending?
    end

    def validate_can_witdraw(application)
      validate_job_open
      raise ApplicationNotFound if application.blank?
      raise ApplicationNotPending unless application.pending?
    end

    def validate_can_accept(application)
      validate_job_open
      validate_available_spots
      raise ApplicationNotFound if application.blank?
      raise ApplicationNotPending unless application.pending?
    end

    def validate_can_reject(application)
      validate_job_open
      raise ApplicationNotFound if application.blank?
      raise ApplicationNotPending unless application.pending?
    end

    def validate_job_open
      raise JobNotOpen unless @state == :created && @starts_on.future?
    end

    def validate_available_spots
      raise NoSpotsAvailable if @available_spots.zero?
    end
  end
end
# rubocop: enable Metrics/ClassLength
