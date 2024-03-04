# frozen_string_literal: true

module Infra
  class ValueObject < Data
    def value
      raise NotImplementedError
    end

    def typed_compound_value
      self.class.typed_value[to_h]
    end

    def self.typed_value
      raise NotImplementedError
    end

    def self.type
      typed_value
    end
  end
end
