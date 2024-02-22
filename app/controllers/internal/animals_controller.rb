class Internal::AnimalsController < ApplicationController
  def index
    @animals = Animals::Animal.all
  end

  def show
    @animal = Animals::Animal.find_by!(uuid: params[:id])
  end

  def new
    @uuid ||= generate_uuid
  end

  def create
    command_bus.call(Administrating::RegisterAnimal.new(
      uuid: params[:uuid],
      registered_by: params[:registered_by]
    ))

    redirect_to internal_animal_path(params[:uuid]), notice: 'Animal was successfully created.'
  rescue Infra::Command::InvalidError => e
    @uuid = params[:uuid]
    render :new
  end

  def add_price
    command_bus.call(Administrating::AddPrice.new(
      uuid: uuid, price: price.to_d)
    )
  end

  private

  def generate_uuid
    SecureRandom.uuid
  end
end
