module Administrating
  class RegisterAnimal < Infra::Command
    attribute :registration_number, Types::Uuid
    attribute :registered_by, Types::FilledString
    alias aggregate_id registration_number # Why??
  end

  class AddPrice < Infra::Command
    attribute :registration_number, Types::Uuid
    attribute :price, Types::Coercible::Decimal
    alias aggregate_id registration_number
  end
end
