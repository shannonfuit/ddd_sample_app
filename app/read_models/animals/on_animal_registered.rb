module Animals
  class OnAnimalRegistered
    def call(event)
      return if Animal.where(registration_number: event.data.fetch(:registration_number)).exists?
      Animal.create(
        registration_number: event.data.fetch(:registration_number),
        registered_by: event.data.fetch(:registered_by)
      )
    end
  end
end
