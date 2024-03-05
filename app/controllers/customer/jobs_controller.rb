# frozen_string_literal: true

module Customer
  class JobsController < ApplicationController
    def index
      @jobs = Customer::Job.all
    end

    def show
      @job = Customer::Job.find_by!(uuid: params[:id])
    end

    def new
      @new ||= generate_uuid
    end

    def create
      command_bus.call(
        JobDrafting::PublishJob.new(
          job_uuid: params[:uuid],
          title: params[:title],
          description: params[:description],
          shift_duration: { starts_on: params[:shift_starts_on], ends_on: params[:shift_ends_on] },
          spots: params[:spots],
          wage_per_hour: params[:wage_per_hour],
          work_location: {
            street: params[:work_location_street],
            house_number: params[:work_location_house_number],
            city: params[:work_location_city],
            zip_code: params[:work_location_zip_code]
          }
        )
      )

      redirect_to customer_job_path(params[:uuid]), notice: 'Job is published.'
    rescue Infra::Command::Invalid
      @uuid = params[:uuid]
      render :new
    end

    private

    def generate_uuid
      SecureRandom.uuid
    end
  end
end
