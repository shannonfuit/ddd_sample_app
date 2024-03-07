# frozen_string_literal: true

module Iam
  class UserCommandHandler < Infra::CommandHandler
    def initialize(**args)
      super
      @repository = Users.new(event_store)
    end
  end

  class OnRegisterAsContact < UserCommandHandler
    def call(command)
      repository.with_user(command.user_uuid) do |user|
        user.register_as_contact(name: command.name, email: command.email)
      end
    end
  end

  class OnRegisterAsCandidate < UserCommandHandler
    def call(command)
      repository.with_user(command.user_uuid) do |user|
        user.register_as_candidate(name: command.name, email: command.email)
      end
    end
  end
end
