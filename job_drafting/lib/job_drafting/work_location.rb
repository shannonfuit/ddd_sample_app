# frozen_string_literal: true

module JobDrafting
  WorkLocation = Infra::ValueObject.define(:street, :house_number, :city, :zip_code) do
    def self.from_address(address)
      new(address.street, address.house_number, address.city, address.zip_code)
    end

    def value
      typed_compound_value
    end

    def self.typed_value
      Infra::Types::StrictSymbolizingHash.schema(
        street: Infra::Types::NotEmpty::String,
        house_number: Infra::Types::String,
        city: Infra::Types::NotEmpty::String,
        zip_code: Infra::Types::NotEmpty::String
      )
    end
  end
end
