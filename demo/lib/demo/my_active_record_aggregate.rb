module Demo
  class MyActiveRecordAggregate
    include Infra::ActiveRecordAggregateRoot

    def initialize(attributes)
      @uuid = attributes[:uuid]
      @amount_of_items = attributes[:amount_of_items] || 0
      puts "*** after initialize"
      puts @amount_of_items
    end

    def do_something_fast
      apply FastItemAdded.new(data: { amount_of_items: @amount_of_items })
      @amount_of_items += 1
      puts "*** on FastItemAdded"
      puts @amount_of_items
    end

    def do_something_slow
      sleep 10
      apply SlowItemAdded.new(data: { amount_of_items: @amount_of_items })
      @amount_of_items += 1
      puts "*** on SlowItemAdded"
      puts @amount_of_items
    end

    def get_state_for_repository
      {
        uuid: @uuid,
        amount_of_items: @amount_of_items
      }
    end
  end
end
