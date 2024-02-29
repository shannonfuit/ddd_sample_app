module Administrating
  class AnimalService
    def initialize(event_store)
      @repository = Animals.new(event_store)
    end
  end

  class OnRegisterAnimal < AnimalService
    def call(command)
      @repository.with_uuid(command.aggregate_id) do |animal|
        animal.register(command)
      end
    end
  end

  class OnRegisterChip < AnimalService
    def call(command)
      @repository.with_uuid(command.aggregate_id) do |animal|
        animal.register_chip(command)
      end
    end
  end

  class OnConfirmChipRegistryChange < AnimalService
    def call(command)
      @repository.with_uuid(command.aggregate_id) do |animal|
        animal.confirm_chip_registry_change(command)
      end
    end
  end
end
