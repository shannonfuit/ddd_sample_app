# frozen_string_literal: true

# rubocop: disable Metrics/ClassLength
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
      @ends_on = nil
      @number_of_spots = nil
      @available_spots = nil
      @applications = Application::Collection.new
    end

    def create(starts_on:, ends_on:, number_of_spots:)
      raise HasAlreadyBeenCreated if @state == :created

      apply JobCreated.new(data: {
                             uuid: @uuid,
                             starts_on:,
                             ends_on:,
                             number_of_spots:
                           })
    end

    def candidate_applies(application_uuid:, candidate_uuid:, motivation:)
      application = @applications.find_by(candidate: candidate_uuid)
      return if application&.pending?

      validate_can_apply(application)

      apply CandidateApplied.new(data: {
                                   uuid: @uuid,
                                   application_uuid:, # late identity generation
                                   candidate_uuid:,
                                   motivation:
                                 })
    end

    def withdraw_application(application_uuid:)
      application = @applications.find_by(uuid: application_uuid)
      return if application&.withdrawn?

      validate_can_witdraw(application)

      apply ApplicationWithdrawn.new(data: {
                                       uuid: @uuid,
                                       application_uuid:
                                     })
    end

    def accept_application(application_uuid:)
      application = @applications.find_by(uuid: application_uuid)
      return if application&.accepted?

      validate_can_accept(application)

      apply ApplicationAccepted.new(data: {
                                      uuid: @uuid,
                                      application_uuid:
                                    })
    end

    def reject_application(application_uuid:)
      application = @applications.find_by(uuid: application_uuid)
      return if application&.rejected?

      validate_can_reject(application)

      apply ApplicationRejected.new(data: {
                                      uuid: @uuid,
                                      application_uuid:
                                    })
    end

    private

    on JobCreated do |event|
      @state = :created
      @starts_on = event.data.fetch(:starts_on)
      @ends_on = event.data.fetch(:ends_on)
      @number_of_spots = event.data.fetch(:number_of_spots)
      @available_spots = event.data.fetch(:number_of_spots)
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

    on ApplicationCancelled do |event|
      application = @applications.find_by(uuid: event.data.fetch(:application_uuid))
      application.cancel(reason: event.data.fetch(:reason))
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
      raise JobNotOpen if @state != :created || @starts_on <= Time.zone.now
    end

    def validate_available_spots
      raise NoSpotsAvailable if @available_spots.zero?
    end
  end
end
# rubocop: enable Metrics/ClassLength
