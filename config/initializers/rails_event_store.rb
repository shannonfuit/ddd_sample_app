# frozen_string_literal: true

require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'

Rails.configuration.to_prepare do
  # We choose for a JSON client, because we store data in postgres as jsonb,
  # By default  RailsEventStore::Client will use YAML
  event_store = RailsEventStore::JSONClient.new(
    dispatcher: RubyEventStore::ComposedDispatcher.new(
      RailsEventStore::AfterCommitAsyncDispatcher.new(
        scheduler: RailsEventStore::ActiveJobScheduler.new(serializer: JSON)
      ),
      RubyEventStore::Dispatcher.new
    )
  )
  command_bus = Arkency::CommandBus.new

  Rails.configuration.command_bus = command_bus
  Rails.configuration.event_store = event_store
  AggregateRoot.configure { |config| config.default_event_store = event_store }

  JobFulfillment::Configuration.new.call(event_store, command_bus)
  JobDrafting::Configuration.new.call(event_store, command_bus)
  Demo::Configuration.new.call(event_store, command_bus)

  Customer::Configuration.new.call(event_store)

  event_store.tap do |store|
    store.subscribe_to_all_events(RailsEventStore::LinkByEventType.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCorrelationId.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCausationId.new)
  end
  #  Event Handlers
  #  Subscribe asynchroniously:
  #  store.subscribe(Animals::OnAnimalRegistered, to: [Administrating::AnimalRegistered])
  #
  #  Subscribe synchroniously (this single instance is used to process all eevents, so keep it stateless)
  #  store.subscribe(Animals::OnAnimalRegistered.new, to: [Administrating::AnimalRegistered])
  #  Subscribe synchroniously (a new instance to process each event) - don't inherit your Handler from ActiveJob
  #  store.subscribe(Animals::OnAnimalRegistered, to: [Administrating::AnimalRegistered])
  #
  #  Specify another method than `call` (Sync only)
  #  store.subscribe( ->(event){ Animals::OnAnimalRegistered.new.foo(event) }, to: [Administrating::AnimalRegistered])
  #  Subscribe to all events:
  #  store.subscribe_to_all_events(Animals::OnAnyEvent) # Async
  #  store.subscribe_to_all_events(Animals::OnAnyEvent.new) # Sync
  #
  #
  #  Command handlers
  #  This handler will be initialized once, make sure it is stateless
  #  command_bus.register(JobDrafting::DraftJob, JobDrafting::OnDraftJob.new(event_store))
  #
  #  This handler will be initialized once per each call, in case each handler needs its own state
  #  command_bus.register(JobDrafting::DraftJob, ->(cmd) { JobDrafting::OnDraftJob.new(event_store).call(cmd) })
end
