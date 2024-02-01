module Administrating
  class Command < Dry::Struct
      # TODO move to superclass
      InvalidError = Class.new(StandardError)

      def self.new(*)
        super
      rescue Dry::Struct::Error => doh
        raise InvalidError, doh
      end
  end

  class RegisterAnimal < Command
    attribute :registration_number, Types::String # TODO: type uuid
    attribute :registered_by, Types::String
    alias aggregate_id registration_number # Why??
  end

  class AddPrice < Command
    attribute :registration_number, Types::String
    attribute :price, Types::Coercible::Decimal
    alias aggregate_id registration_number
  end
end
