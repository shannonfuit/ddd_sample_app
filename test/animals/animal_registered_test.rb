# frozen_string_literal: true

require 'test_helper'

module Animals
  class AnimalRegisteredTest < ActiveSupport::TestCase
    # include TestHelpers::Integration

    # cover 'Animals::OnAnimalRegistered*'

    test 'registering an animal that does not exist' do
      event_store = Rails.configuration.event_store
      uuid = SecureRandom.uuid
      registered_by = 'Sjaan'
      event_store.publish(Administrating::AnimalRegistered.new(data: { animal_uuid: uuid, registered_by: 'Sjaan' }))

      assert_equal(1, Animal.count)
      animal = Animal.find_by(uuid:)
      assert_equal(uuid, animal.uuid)
      assert_equal(registered_by, animal.registered_by)
    end

    test 'skip when duplicated' do
      event_store = Rails.configuration.event_store
      uuid = SecureRandom.uuid
      registered_by = 'Sjaan'
      event_store.publish(Administrating::AnimalRegistered.new(data: { animal_uuid: uuid,
                                                                       registered_by: }))
      event_store.publish(Administrating::AnimalRegistered.new(data: { animal_uuid: uuid,
                                                                       registered_by: }))

      assert_equal(1, Animal.count)
      animal = Animal.find_by(uuid:)
      assert_equal(uuid, animal.uuid)
      assert_equal(registered_by, animal.registered_by)
    end
  end
end
