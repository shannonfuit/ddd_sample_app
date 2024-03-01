# frozen_string_literal: true

module Animals
  class OnAnimalRegistered < Infra::EventHandler
    def call(event)
      return if Animal.exists?(uuid: event.data.fetch(:animal_uuid))

      Animal.create(
        uuid: event.data.fetch(:animal_uuid),
        registered_by: event.data.fetch(:registered_by)
      )
    end
  end
end
