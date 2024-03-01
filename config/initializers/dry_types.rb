# frozen_string_literal: true

module Types
  include Dry.Types

  Greeting = String.enum('Hello', 'Hola')

  UUID_REGEX = /\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/i
  Uuid = String.constrained(format: UUID_REGEX, filled: true)
  FilledString = String.constrained(filled: true)
end
