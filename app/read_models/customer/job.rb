# frozen_string_literal: true

module Customer
  class Job < ApplicationRecord
    self.table_name = 'customer_jobs'

    DRAFT = 'draft'
    PUBLISHED = 'published'
    UNPUBLISHED = 'unpublished'

    APPLICATION_PENDING = 'pending'
    APPLICATION_WITHDRAWN = 'withdrawn'
    APPLICATION_ACCEPTED = 'accepted'
    APPLICATION_REJECTED = 'rejected'

    def taken_spots
      applications.count { |app| app['status'] == APPLICATION_ACCEPTED }
    end

    def can_unpublish?
      status == PUBLISHED
    end

    def open_spots?
      spots > taken_spots
    end
  end
end
