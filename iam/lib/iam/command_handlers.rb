# frozen_string_literal: true

module Iam
  class CompanyCommandHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = Companies.new(event_store)
    end
  end

  class UserCommandHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = Users.new(event_store)
    end
  end

  class OnRegisterCompany < CompanyCommandHandler
    def call(command)
      repository.with_company(command.company_uuid) do |company|
        company.register(name: command.name)
      end
    end
  end

  class OnRegisterAsContact < UserCommandHandler
    def call(command)
      repository.transaction do
        # check if company exists
        repository.with_user(command.user_uuid) do |user|
          user.register_as_contact(name: command.name, email: command.email, company_uuid: command.company_uuid)
        end
      end
    end
  end

  class OnRegisterAsCandidate < UserCommandHandler
    def call(command)
      repository.transaction do
        repository.with_user(command.user_uuid) do |user|
          user.register_as_candidate(name: command.name, email: command.email)
        end
      end
    end
  end
end
