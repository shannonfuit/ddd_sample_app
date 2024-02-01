module Administrating
  class OnRegisterAnimal
    def initialize(event_store)
      @repository = Animals.new(event_store)
    end

    def call(command)
      @repository.with_registration_number(command.registration_number) do |animal|
        animal.register(command)
      end
    end
  end

  class OnAddPrice
    def initialize(event_store)
      @repository = Animals.new(event_store)
    end

    def call(command)
      @repository.with_registration_number(command.registration_number) do |animal|
        animal.add_price(command)
      end
    end
  end
end
