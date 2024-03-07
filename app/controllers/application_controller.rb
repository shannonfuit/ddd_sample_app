# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # before_action :configure_permitted_parameters, if: :devise_controller?
  def command_bus
    Rails.configuration.command_bus
  end

  def event_store
    Rails.configuration.event_store
  end

  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up, keys: %i[attribute1 attribute2])
  #   # Add attributes for each model as needed
  # end
end
