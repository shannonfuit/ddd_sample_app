require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new
  Rails.configuration.command_bus = Arkency::CommandBus.new


  AggregateRoot.configure do |config|
    config.default_event_store = Rails.configuration.event_store
  end

  # Subscribe event handlers below
  Rails.configuration.event_store.tap do |store|
    store.subscribe(Animals::OnAnimalRegistered, to: [Administrating::AnimalRegistered])
    # store.subscribe(InvoiceReadModel.new, to: [InvoicePrinted])
    # store.subscribe(lambda { |event| SendOrderConfirmation.new.call(event) }, to: [OrderSubmitted])
    # store.subscribe_to_all_events(lambda { |event| Rails.logger.info(event.event_type) })

    store.subscribe_to_all_events(RailsEventStore::LinkByEventType.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCorrelationId.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCausationId.new)
  end

  # Register command handlers below
  Rails.configuration.command_bus.tap do |bus|
    event_store = Rails.configuration.event_store
    bus.register(Administrating::RegisterAnimal, Administrating::OnRegisterAnimal.new(event_store))
    bus.register(Administrating::RegisterChip, Administrating::OnRegisterChip.new(event_store))
    bus.register(Administrating::ConfirmChipRegistryChange, Administrating::OnConfirmChipRegistryChange.new(event_store))
  # this handler will be initialized once, make sure it is stateless
  # bus.register(PrintInvoice, Invoicing::OnPrint.new)
  #
  # this handler will be initialized once per each call, in case each handler needs its own state
  # bus.register(SubmitOrder, ->(cmd) { Ordering::OnSubmitOrder.new.call(cmd) })
  end
end
