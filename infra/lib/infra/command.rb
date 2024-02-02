module Infra
  class Command < Dry::Struct
    class InvalidError < StandardError
      attr_reader :original_error

      def initialize(original_error)
        super(original_error.message)
        @original_error = original_error
      end
    end

    def self.new(*)
      super
    rescue Dry::Struct::Error => original_error
      raise InvalidError, original_error
    end
  end
end
