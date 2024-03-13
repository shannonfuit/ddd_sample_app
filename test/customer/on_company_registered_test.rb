# frozen_string_literal: true

require 'test_helper'

module Customer
  class OnCompanyPublishedTest < Infra::ReadModelTestHelper
    setup do
      @company_uuid = SecureRandom.uuid
    end

    test 'create a candidate that does not exist' do
      event_store.publish(company_registered)

      assert_equal(1, Company.count)
      assert_equal(
        {
          uuid: @company_uuid,
          name: 'HelloFresh'
        }, company_attributes
      )
    end

    test 'skip when duplicated' do
      Customer::CompanyEventHandlers::OnCompanyRegistered.new.call(company_registered)
      Customer::CompanyEventHandlers::OnCompanyRegistered.new.call(company_registered)

      assert_equal(1, Company.count)
    end

    def company_attributes
      company = Company.find_by(uuid: @company_uuid)
      company&.attributes&.deep_symbolize_keys&.slice(
        :uuid, :name
      )
    end

    def company_registered
      Iam::CompanyRegistered.new(
        data: {
          company_uuid: @company_uuid,
          name: 'HelloFresh'
        }
      )
    end
  end
end
