require 'test_helper'

module Administrating
  class RegisterAnimalTest < Infra::DomainTestHelper
    test 'animal is registered' do
      uuid = SecureRandom.uuid
      registered_by = "Sjaan"
      stream = "Administrating::Animal$#{uuid}"
      published = act(stream, Administrating::RegisterAnimal.new(uuid: uuid, registered_by: registered_by))
      assert_changes(published, [AnimalRegistered.new(data: { animal_uuid: uuid, registered_by: registered_by })])
    end

    test 'animal can only be registered once' do
      uuid = SecureRandom.uuid
      registered_by = "Sjaan"
      stream = "Administrating::Animal$#{uuid}"
      arrange(stream, [
        Administrating::AnimalRegistered.new(data: {animal_uuid: uuid, registered_by: registered_by})
      ])

      assert_raises(Animal::HasAlreadyBeenRegistered) do
        act(stream, Administrating::RegisterAnimal.new(uuid: uuid, registered_by: registered_by))
      end
    end
  end
end
