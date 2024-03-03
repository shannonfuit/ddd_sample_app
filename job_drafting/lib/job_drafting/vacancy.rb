# frozen_string_literal: true

module JobDrafting
  Vacancy = Infra::ValueObject.define(:title, :description, :dress_code_requirements) do
    def value
      typed_compound_value
    end

    def self.typed_value
      Infra::Types::StrictSymbolizingHash.schema(
        title: Infra::Types::NotEmpty::String,
        description: Infra::Types::NotEmpty::String,
        dress_code_requirements: Infra::Types::NotEmpty::String.optional
      )
    end
  end
end
