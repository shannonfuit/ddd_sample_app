module Administrating
  class Animal
    include AggregateRoot

    class HasAlreadyBeenRegistered < StandardError; end
    class NotRegistered < StandardError; end
    class NoPriceSet < StandardError; end

    def initialize
      @state = :new
      @price = nil
      @registered_by = nil
    end

    def register(command)
      raise HasAlreadyBeenRegistered if @state == :registered
      apply AnimalRegistered.new(data: {
        registration_number: command.registration_number,
        registered_by: command.registered_by
      })
    end

    def add_price(command)
      raise NotRegistered if @state != :registered
      apply AnimalPriceAdded.new(data: {
        price: command.price
      })
    end

    on AnimalRegistered do |event|
      @state = :registered
      @registered_by = event.data.fetch(:registered_by)
    end

    on AnimalPriceAdded do |event|
      @price = event.data.fetch(:price)
    end

    private

    attr_reader :state
  end
end
