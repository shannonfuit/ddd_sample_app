# frozen_string_literal: true

require 'test_helper'

module Customer
  class OnCandidatePublishedTest < Infra::ReadModelTestHelper
    setup do
      @candidate_uuid = SecureRandom.uuid
    end

    test 'create a candidate that does not exist' do
      event_store.publish(candidate_registered)

      assert_equal(1, Candidate.count)
      assert_equal(
        {
          uuid: @candidate_uuid,
          first_name: 'John',
          last_name: 'Doe'
        }, candidate_attributes
      )
    end

    test 'skip when duplicated' do
      Customer::CandidateEventHandlers::OnCandidateRegistered.new.call(candidate_registered)
      Customer::CandidateEventHandlers::OnCandidateRegistered.new.call(candidate_registered)

      assert_equal(1, Candidate.count)
    end

    def candidate_attributes
      candidate = Candidate.find_by(uuid: @candidate_uuid)
      candidate&.attributes&.deep_symbolize_keys&.slice(
        :uuid, :first_name, :last_name
      )
    end

    def candidate_registered
      Iam::CandidateRegistered.new(
        data: {
          user_uuid: @candidate_uuid,
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@gmail.com'
        }
      )
    end
  end
end
