# frozen_string_literal: true

module Infra
  # A value object is an compound attribute, instead of a primitive attribute
  # like a String or an Integer. It is immutable and should be compared by
  # its attributes.
  # Behaviour:
  # it can have multiple factory methods and methods to return a
  # (changed) copy of the value object. It also can have query method
  # or perform calculations like adding two objects or iterating over them
  class ValueObject
    # @param attributes [Array<Object>]
    # @return [ValueObject] A new instance immutable of the value object
    # @raise [ArgumentError] If the number of attributes is different
    # from the number of attributes defined in the class
    def initialize(*attributes)
      @attributes = attributes
    end

    # @return [Array<Object>] The attributes of the value object
    def with_immutability
      yield
      freeze
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      attributes == other.attributes
    end

    alias eql? ==

    def hash
      [self.class, attributes].hash
    end

    protected

    attr_reader :attributes
  end
end
