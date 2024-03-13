# frozen_string_literal: true

module Demo
  class MyActiveRecordAggregate
    include Infra::ActiveRecordAggregateRoot

    def initialize(attributes)
      @uuid = attributes[:uuid]
      @amount_of_items = attributes[:amount_of_items] || 0
      puts '*** after initialize'
      puts @amount_of_items
    end

    def do_something_fast
      @amount_of_items += 1
      apply FastItemAdded.new(data: { amount_of_items: @amount_of_items })
      puts '*** on FastItemAdded'
      puts "Amount of items is now: #{@amount_of_items}"
    end

    def do_something_slow
      sleep 10
      @amount_of_items += 1
      apply SlowItemAdded.new(data: { amount_of_items: @amount_of_items })
      puts '*** on SlowItemAdded'
      puts "Amount of items is now: #{@amount_of_items}"
    end

    def state_for_repository
      {
        uuid: @uuid,
        amount_of_items: @amount_of_items
      }
    end
  end
end
