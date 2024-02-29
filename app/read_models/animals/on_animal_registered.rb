module Animals
  class OnAnimalRegistered < Infra::EventHandler
    def call(event)
      return if Animal.where(uuid: event.data.fetch(:animal_uuid)).exists?
      Animal.create(
        uuid: event.data.fetch(:animal_uuid),
        registered_by: event.data.fetch(:registered_by)
      )
    end
  end
end
