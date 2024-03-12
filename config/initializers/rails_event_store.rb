# frozen_string_literal: true

require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'

Rails.configuration.to_prepare do
  # We choose for a JSON client, because we store data in postgres as jsonb,
  # By default  RailsEventStore::Client will use YAML
  event_store = Infra::EventStore.main
  command_bus = Infra::CommandBus.main

  # Configure Rails.configuration
  Rails.configuration.command_bus = command_bus
  Rails.configuration.event_store = event_store

  # This is configured in the test_helpers of the bounded contexts
  unless Rails.env.test?
    # Configure aggregate root
    AggregateRoot.configure { |config| config.default_event_store = event_store }

    # Configure domain
    Iam.configure(command_bus, event_store)
    JobDrafting.configure(command_bus, event_store)
    JobFulfillment.configure(command_bus, event_store)
    Demo.configure(command_bus, event_store)

    # Configure read models
    Customer.configure(event_store)
  end

  # For debugging purposes
  event_store.tap do |store|
    store.subscribe_to_all_events(RailsEventStore::LinkByEventType.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCorrelationId.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCausationId.new)
  end

  #  Samples:
  #
  #  Event Handlers
  #  Subscribe asynchroniously:
  #  store.subscribe(JobDrafting::OnJobPublished, to: [JobDrafting::JobPublished])
  #
  #  Subscribe synchronously (this single instance is used to process all eevents, so keep it stateless)
  #  store.subscribe(JobDrafting::OnJobPublished.new, to: [JobDrafting::JobPublished])
  #
  #  Subscribe synchroniously (a new instance to process each event) - don't inherit your Handler from ActiveJob
  #  store.subscribe(JobDrafting::OnJobPublished, to: [JobDrafting::JobPublished])
  #
  #  Specify another method than `call` (Sync only)
  #  store.subscribe( -(event)){ JobDrafting::OnJobPublished.new.foo(event) }, to: [JobDrafting::JobPublished]
  #
  #  Subscribe to all events:
  #  store.subscribe_to_all_events(Customer::OnAnyEvent)
  #  store.subscribe_to_all_events(Customer::OnAnyEvent) # Async
  #  store.subscribe_to_all_events(Customer::OnAnyEvent.new) # Sync
  #
  #
  #  Command handlers
  #  This handler will be initialized once, make sure it is stateless
  #  command_bus.register(JobDrafting::PublishJob, JobDrafting::OnPublishJob.new(event_store))
  #
  #  This handler will be initialized once per each call, in case each handler needs its own state
  #  command_bus.register(JobDrafting::PublishJob, ->(cmd) { JobDrafting::OnPublishJob.new(event_store).call(cmd) })
end
