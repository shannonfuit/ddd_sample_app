# frozen_string_literal: true

require 'test_helper'

module Administrating
  class RegisterChipTest < Infra::DomainTestHelper
    test 'a chip is registered' do
      uuid = SecureRandom.uuid
      registered_by = 'Sjaan'
      stream = "Administrating::Animal$#{uuid}"
      arrange(stream, [
                Administrating::AnimalRegistered.new(data: { animal_uuid: uuid, registered_by: })
              ])
      published = act(stream, RegisterChip.new(uuid:, number: 12_345, registry: 'ThirdPartyRegistry'))
      assert_changes(published,
                     [ChipRegistered.new(data: { animal_uuid: uuid, number: 12_345, registry: 'ThirdPartyRegistry' })])
    end

    test 'a chip is added to an animal that is not registered' do
      uuid = SecureRandom.uuid
      stream = "Administrating::Animal$#{uuid}"

      assert_raises(Animal::NotRegistered) do
        act(stream, RegisterChip.new(uuid:, number: 12_345, registry: 'ThirdPartyRegistry'))
      end
    end
  end
end
