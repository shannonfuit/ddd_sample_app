# frozen_string_literal: true

module Customer
  module CompanyEventHandlers
    class EventHandler < Infra::EventHandler; end

    class OnCompanyRegistered < EventHandler
      def call(event)
        return if Company.exists?(uuid: event.data.fetch(:company_uuid))

        Company.create(
          uuid: event.data.fetch(:company_uuid),
          name: event.data.fetch(:name)
        )
      end
    end
  end
end
