class Internal::AnimalsController < ApplicationController
  def index
    @animals = Animals::Animal.all
  end

  def show
    @animal = Animals::Animal.find_by!(registration_number: params[:id])
  end

  def new
    @registration_number = SecureRandom.uuid
  end

  def create
    command_bus.call(Administrating::RegisterAnimal.new(
      registration_number: params[:registration_number],
      registered_by: params[:registered_by])
    )
  end

  def add_price
    command_bus.call(Administrating::AddPrice.new(
      registration_number: registration_number, price: price.to_d)
    )
  end
end
