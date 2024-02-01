module Types
  include Dry.Types

  Greeting = String.enum("Hello", "Hola")
end
