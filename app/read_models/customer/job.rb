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
  end
end
