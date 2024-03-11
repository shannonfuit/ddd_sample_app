# frozen_string_literal: true

class Candidate < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_create :generate_uuid

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
