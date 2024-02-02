module Administrating
  class AnimalPriceAdded < Infra::Event
    attribute :registration_number, Types::String # TODO: uuid type
  end
end
