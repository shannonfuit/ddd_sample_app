module Infra
  module ActiveRecordAggregateRoot
    def unpublished_events
      @unpublished_events ||= []
    end

    private

    def apply(*events)
      events.each {|event| unpublished_events << event}
    end
  end
end
