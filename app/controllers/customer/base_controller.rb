# frozen_string_literal: true

module Customer
  class BaseController < ApplicationController
    before_action :authenticate_contact!
  end
end
