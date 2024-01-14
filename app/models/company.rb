# frozen_string_literal: true

class Company < ApplicationRecord
  # validates :name, presence: true
  #
  def hello_world
    Rails.logger.debug 'hello world'
  end
end
