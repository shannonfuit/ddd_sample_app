class ApplicationController < ActionController::Base
  def command_bus
    Rails.configuration.command_bus
  end
end
