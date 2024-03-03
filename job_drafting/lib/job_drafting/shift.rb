# frozen_string_literal: true

module JobDrafting
  Shift = Infra::ValueObject.define(:starts_on, :ends_on) do
    delegate :future?, to: :starts_on

    def self.from_duration(duration)
      new(duration.starts_on, duration.ends_on)
    end

    def value
      typed_compound_value
    end

    def self.typed_value
      Infra::Types::StrictSymbolizingHash.schema(
        starts_on: Infra::Types::Time,
        ends_on: Infra::Types::Time
      )
    end
  end
end
