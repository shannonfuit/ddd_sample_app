# frozen_string_literal: true

module Demo
  class MyEventSourcedAggregate
    include AggregateRoot

    def initialize(uuid)
      @uuid = uuid
      @amount_of_items = 0
    end

    def do_something_fast
      apply FastItemAdded.new(data: { amount_of_items: @amount_of_items })
    end

    def do_something_slow
      sleep 10
      apply SlowItemAdded.new(data: { amount_of_items: @amount_of_items })
    end

    on FastItemAdded do |_event|
      @amount_of_items += 1
      puts '*** on FastItemAdded'
      puts "Amount of items is now: #{@amount_of_items}"
    end

    on SlowItemAdded do |_event|
      @amount_of_items += 1
      puts '*** on SlowItemAdded'
      puts "Amount of items is now: #{@amount_of_items}"
    end
  end
end
