# frozen_string_literal: true

require 'test_helper'

module Infra
  class ValueObjectTest < ActiveSupport::TestCase
    MyValueObject = ValueObject.define(:name, :age)
    AnotherValueObject = ValueObject.define(:name, :age)

    def setup
      @obj1 = MyValueObject.new('John', 30)
      @obj2 = MyValueObject.new('John', 30)
      @obj4 = MyValueObject.new('Jane', 30)
      @obj5 = MyValueObject.new('John', 35)
      @obj6 = AnotherValueObject.new('Jane', 35)
    end

    test 'equality' do
      assert_equal @obj1, @obj2
      assert_not_equal @obj1, @obj4
      assert_not_equal @obj1, @obj5
      assert_not_equal @obj1, @obj6
    end

    test 'hash equality' do
      assert_equal @obj1.hash, @obj2.hash
      assert_not_equal @obj1.hash, @obj4.hash
      assert_not_equal @obj2.hash, @obj5.hash
      assert_not_equal @obj1.hash, @obj3.hash
      assert_not_equal @obj1.hash, @obj6.hash
    end
  end
end
