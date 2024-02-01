module Administrating
  class Event < RubyEventStore::Event
  end

  class AnimalPriceAdded < Event
    attribute :registration_number, Types::String # TODO: uuid type
  end
end
