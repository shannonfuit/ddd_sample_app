# frozen_string_literal: true

module Customer
  class JobsController < BaseController
    def index
      @jobs = Customer::Job.all
    end

    def show
      @job = Customer::Job.find_by!(uuid: params[:id])
    end

    def new
      @new ||= SecureRandom.uuid
    end

    def create
      command_bus.call(
        JobDrafting::PublishJob.new(
          job_uuid: params[:job_uuid],
          contact_uuid: current_user.uuid,
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

      redirect_to customer_job_path(params[:job_uuid]), notice: 'Job is published.'
    rescue Infra::Command::Invalid => e
      flash.now[:alert] = e.message
      Rails.logger.debug e.message
      @uuid = params[:uuid]
      render :new
    end

    private

    def generate_uuid
      SecureRandom.uuid
    end
  end
end
