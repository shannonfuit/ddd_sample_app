# frozen_string_literal: true

module App
  class BaseController < ApplicationController
    before_action :authenticate_candidate!
  end
end
