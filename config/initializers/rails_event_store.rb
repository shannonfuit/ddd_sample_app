require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"

Rails.configuration.to_prepare do
# We choose for a JSON client, because we store data in postgres as jsonb,
# By default  RailsEventStore::Client will use YAML
  Rails.configuration.event_store = RailsEventStore::JSONClient.new(
    dispatcher: RubyEventStore::ComposedDispatcher.new(
      RailsEventStore::AfterCommitAsyncDispatcher.new(scheduler: RailsEventStore::ActiveJobScheduler.new(serializer: JSON)),
      RubyEventStore::Dispatcher.new
    )
  )

  Rails.configuration.command_bus = Arkency::CommandBus.new

  AggregateRoot.configure do |config|
    config.default_event_store = Rails.configuration.event_store
  end

  # Subscribe event handlers below
  Rails.configuration.event_store.tap do |store|
   store.subscribe(Animals::OnAnimalRegistered.new, to: [Administrating::AnimalRegistered])

    store.subscribe_to_all_events(RailsEventStore::LinkByEventType.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCorrelationId.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCausationId.new)
  end
  # examples:
  #  Subscribe asynchroniously:
  #  store.subscribe(Animals::OnAnimalRegistered, to: [Administrating::AnimalRegistered])
  #
  #  Subscribe synchroniously (this single instance is used to process all eevents, so keep it stateless)
  #  store.subscribe(Animals::OnAnimalRegistered.new, to: [Administrating::AnimalRegistered])
  #  Subscribe synchroniously (a new instance to process each event) - don't inherit your Handler from ActiveJob
  #  store.subscribe(Animals::OnAnimalRegistered, to: [Administrating::AnimalRegistered])

  #  Specify another method than `call` (Sync only)
  #  store.subscribe( ->(event){ Animals::OnAnimalRegistered.new.foo(event) }, to: [Administrating::AnimalRegistered])
  #  Subscribe to all events:
  #  store.subscribe_to_all_events(Animals::OnAnyEvent) # Async
  #  store.subscribe_to_all_events(Animals::OnAnyEvent.new) # Sync



  # Register command handlers below
  Rails.configuration.command_bus.tap do |bus|
    event_store = Rails.configuration.event_store
    bus.register(Administrating::RegisterAnimal, Administrating::OnRegisterAnimal.new(event_store))
    bus.register(Administrating::RegisterChip, Administrating::OnRegisterChip.new(event_store))
    bus.register(Administrating::ConfirmChipRegistryChange, Administrating::OnConfirmChipRegistryChange.new(event_store))

    # this handler will be initialized once, make sure it is stateless
  # bus.register(Administrating::RegisterAnimal, Administrating::OnRegisterAnimal.new(event_store))
  #
  # this handler will be initialized once per each call, in case each handler needs its own state
  # bus.register(Administrating::RegisterAnimal, ->(cmd) {  Administrating::OnRegisterAnimal.new(event_store).call(cmd) })
  end
end
