require 'test_helper'

module Infra
  class ValueObjectTest < ActiveSupport::TestCase
    class MyValueObject < ValueObject
      attr_reader :name, :age

      def initialize(name, age)
        @name = name
        @age = age
        super(name, age)
      end
    end

    class AnotherValueObject < ValueObject
      def initialize(name, age)
        @name = name
        @age = age
        super(name, age)
      end
    end

    class MySubValueObject < MyValueObject
    end

    def setup
      @obj1 = MyValueObject.new('John', 30)
      @obj2 = MyValueObject.new('John', 30)
      @obj3 = MySubValueObject.new('John', 30)
      @obj4 = MyValueObject.new('Jane', 30)
      @obj5 = MyValueObject.new('John', 35)
      @obj6 = AnotherValueObject.new('Jane', 35)
    end

    test 'equality' do
      assert_equal @obj1, @obj2
      assert_equal @obj1, @obj3
      refute_equal @obj1, @obj4
      refute_equal @obj1, @obj5
      refute_equal @obj1, @obj6
    end

    test 'hash equality' do
      assert_equal @obj1.hash, @obj2.hash
      refute_equal @obj1.hash, @obj4.hash
      refute_equal @obj2.hash, @obj5.hash
      refute_equal @obj1.hash, @obj3.hash
      refute_equal @obj1.hash, @obj6.hash
    end
  end
end
