# frozen_string_literal: true

module Infra
  module Types
    include Dry.Types

    class SymbolizeStruct < Dry::Struct
      transform_keys(&:to_sym)
    end

    UUID =
      Types::Strict::String.constrained(
        format: /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\z/i
      )
    ID = Types::Strict::Integer
    Spots = Types::Strict::Integer.constrained(gt: 0)
    Money = Types::Coercible::Decimal.constrained(gt: 0)
    module NotEmpty
      String = Types::Strict::String.constrained(format: /\S/)
    end
    StrictSymbolizingHash = Types::Hash.schema({}).strict.with_key_transform(&:to_sym)

    class TimeRange < SymbolizeStruct
      attribute :starts_on, Types::Time
      attribute :ends_on, Types::Time

      def initialize(*)
        super
        raise ArgumentError, 'starts_on cannot before ends_on' if starts_on > ends_on
      end

      def range
        starts_on..ends_on
      end
    end

    class Address < SymbolizeStruct
      attribute :street, NotEmpty::String
      attribute :house_number, Types::String
      attribute :city, NotEmpty::String
      attribute :zip_code, NotEmpty::String
    end

    class Name < SymbolizeStruct
      attribute :first_name, NotEmpty::String
      attribute :last_name, NotEmpty::String
      attribute? :middle_name, Types::NotEmpty::String.optional
    end
  end
end
