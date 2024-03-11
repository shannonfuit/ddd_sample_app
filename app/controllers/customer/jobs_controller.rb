# frozen_string_literal: true

module Customer
  class JobsController < BaseController
    # TODO: scope this to the current contact
    def index
      @jobs = Customer::Job.all
    end

    def show
      @job = Customer::Job.find_by!(uuid: params[:uuid])
    end

    def new
      @uuid = SecureRandom.uuid
    end

    def create
      command_bus.call(
        JobDrafting::PublishJob.new(
          job_uuid: params[:uuid],
          contact_uuid: current_contact.uuid,
          title: params[:title],
          description: params[:description],
          dress_code_requirements: params[:dress_code_requirements],
          shift_duration: {
            starts_on: Time.zone.parse(params[:shift_starts_on]),
            ends_on: Time.zone.parse(params[:shift_ends_on])
          },
          spots: params[:spots].to_i,
          wage_per_hour: params[:wage_per_hour],
          work_location: {
            street: params[:work_location][:street],
            house_number: params[:work_location][:house_number],
            city: params[:work_location][:city],
            zip_code: params[:work_location][:zip_code]
          }
        )
      )

      redirect_to customer_job_url(params[:uuid]), notice: 'Job was Published.'
    rescue Infra::Command::Invalid => e
      # TODO: Non happy flow
      flash.now[:alert] = e.message
      @uuid = params[:uuid]
      render :new
    end

    def unpublish
      command_bus.call(
        JobDrafting::UnpublishJob.new(
          job_uuid: params[:uuid],
          contact_uuid: current_contact.uuid
        )
      )

      redirect_to customer_job_url(params[:uuid]), notice: 'Job was successfully unpublished.'
    rescue StandardError
      # TODO: Non happy flow
    end

    def accept_application
      command_bus.call(
        JobFulfillment::AcceptApplication.new(
          job_uuid: params[:uuid],
          application_uuid: params[:application_uuid],
          contact_uuid: current_contact.uuid
        )
      )

      redirect_to customer_job_url(params[:uuid]), notice: 'Application was accepted.'
    rescue StandardError
      # TODO: non happy flow
    end

    def reject_application
      command_bus.call(
        JobFulfillment::RejectApplication.new(
          job_uuid: params[:uuid],
          application_uuid: params[:application_uuid],
          contact_uuid: current_contact.uuid
        )
      )

      redirect_to customer_job_url(params[:uuid]), notice: 'Application was rejected.'
    rescue StandardError
      # TODO: non happy flow
    end
  end
end
