require 'test_helper'

module Administrating
  class RegisterAnimalTest < Infra::DomainTestHelper
    # TODO: move to helper
    # def arrange(stream, events)
    #   events.each { |event| event_store.publish(event, stream_name: stream) }
    # end

    # def act(stream, command)
    #   before = event_store.read.stream(stream).each.to_a
    #   command_bus.call(command)
    #   after = event_store.read.stream(stream).each.to_a
    #   after.reject { |a| before.any? { |b| a.event_id == b.event_id } }
    # end

    # def assert_changes(actuals, expected)
    #   expects = expected.map(&:data)
    #   assert_equal(expects, actuals.map(&:data))
    # end

    # def assert_no_changes(actuals)
    #   assert_empty(actuals)
    # end

    # def command_bus
    #   Rails.configuration.command_bus
    # end

    # def event_store
    #   Rails.configuration.event_store
    # end

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
