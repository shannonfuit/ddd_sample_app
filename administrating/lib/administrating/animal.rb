# frozen_string_literal: true

module Administrating
  class Animal
    include AggregateRoot

    class HasAlreadyBeenRegistered < StandardError; end
    class NotRegistered < StandardError; end

    def initialize
      @state = :new
      @chip = nil
      @registered_by = nil
    end

    def register(command)
      raise HasAlreadyBeenRegistered if @state == :registered

      apply AnimalRegistered.new(data: {
                                   animal_uuid: command.uuid,
                                   registered_by: command.registered_by
                                 })
    end

    def register_chip(command)
      raise NotRegistered if @state != :registered

      apply ChipRegistered.new(data: {
                                 animal_uuid: command.uuid,
                                 number: command.number,
                                 registry: command.registry
                               })
    end

    def confirm_chip_registry_change(command)
      raise NotRegistered if @state != :registered

      apply ChipRegistryChangeConfirmed.new(data: {
                                              animal_uuid: command.uuid
                                            })
    end

    # def add_veterinary_visit(command)
    #   raise NotRegistered if @state != :registered
    #   apply VeterinaryVisitAdded.new(data: {
    #     animal_uuid: command.uuid,
    #     veterinary: command.price
    #   })
    # end

    on AnimalRegistered do |event|
      @state = :registered
      @registered_by = event.data.fetch(:registered_by)
    end

    on ChipRegistered do |event|
      @chip = Chip.new(event.data.fetch(:number), event.data.fetch(:registry))
    end

    on ChipRegistryChangeConfirmed do |_event|
      @chip = @chip.confirm_registry_change
    end

    private

    attr_reader :state
  end
end
