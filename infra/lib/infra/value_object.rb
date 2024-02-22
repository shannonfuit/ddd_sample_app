module Infra
  class ValueObject
    # @param attributes [Array<Object>]
    #
    def initialize(*attributes)
      @attributes = attributes
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      self.attributes == other.attributes
    end

    alias eql? ==

    def hash
      [self.class, attributes].hash
    end

    protected

    attr_reader :attributes
  end
end
