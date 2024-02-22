module Administrating
  class Chip < Infra::ValueObject
    attr_reader :number, :registry, :registry_change_confirmed

    def initialize(number, registry, registry_change_confirmed = false)
      super
      @number = number
      @registry = registry
      @registry_change_confirmed = registry_change_confirmed

      raise ArgumentError, 'number cant be nil' if number.nil?
      raise ArgumentError, 'registry cant be nil' if registry.nil?
    end

    def confirm_registry_change
      self.class.new(number, registry, true)
    end
  end
end
