# frozen_string_literal: true

module Customer
  class Company < ApplicationRecord
    self.table_name = 'customer_companies'
  end
end
