require 'test_helper'

module Animals
  class AnimalRegisteredTest < ActiveSupport::TestCase
    # include TestHelpers::Integration

    # cover 'Animals::OnAnimalRegistered*'

    test 'registering an animal that does not exist' do
      event_store = Rails.configuration.event_store
      registration_number = SecureRandom.uuid
      registered_by = "Sjaan"
      event_store.publish(Administrating::AnimalRegistered.new(data: { registration_number: registration_number, registered_by: "Sjaan" }))

      assert_equal(1, Animal.count)
      animal = Animal.find_by(registration_number: registration_number)
      assert_equal(registration_number, animal.registration_number)
      assert_equal(registered_by, animal.registered_by)
    end

    test 'skip when duplicated' do
      event_store = Rails.configuration.event_store
      registration_number = SecureRandom.uuid
      registered_by = "Sjaan"
      event_store.publish(Administrating::AnimalRegistered.new(data: { registration_number: registration_number, registered_by: registered_by }))
      event_store.publish(Administrating::AnimalRegistered.new(data: { registration_number: registration_number, registered_by: registered_by }))

      assert_equal(1, Animal.count)
      animal = Animal.find_by(registration_number: registration_number)
      assert_equal(registration_number, animal.registration_number)
      assert_equal(registered_by, animal.registered_by)
    end
  end
end
