# frozen_string_literal: true

module Customer
  class Candidate < ApplicationRecord
    self.table_name = 'customer_candidates'

    def name
      "#{first_name} #{last_name}"
    end
  end
end
