module Demo
  class MyEventSourcedAggregate
    include EventSourcedAggregateRoot

    def initialize(uuid)
      @amount_of_items = 0
    end

    def do_something_fast
      apply FastItemAdded.new(data: { amount_of_items: @amount_of_items })
    end

    def do_something_slow
      sleep 10
      apply SlowItemAdded.new(data: { amount_of_items: @amount_of_items })
    end

    on FastItemAdded do |event|
      @amount_of_items += 1
      puts "*** on FastItemAdded"
      puts @amount_of_items
    end

    on SlowItemAdded do |event|
      @amount_of_items += 1
      puts "*** on FastSlowAdded"
      puts @amount_of_items
    end
  end
end
