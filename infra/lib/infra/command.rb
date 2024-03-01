require 'dry-schema'
require 'active_model'

# TODO: support injection of locale
module Infra
  class Command
    include ActiveModel::Model
    include ActiveModel::Attributes

    Dry::Schema.load_extensions(:json_schema)

    # @param [Hash] args
    # @raise [InvalidError] when the args are invalid
    # @raise [InvalidError] when the args are nil
    # @raise [InvalidError] when the args are not keyword arguments
    # @return [Command]
    # @example
    #  class MyCommand < Infra::Command
    #  configure_schema do |config|
    #  config.required(:uuid).filled(:string)
    #   config.required(:registered_by).filled(:string)
    #   end
    # end
    # see Dry-validation docs for more information on the schema
    def initialize(*args)
      raise InvalidError, 'arguments cannot be nil' if args.first.nil?
      raise InvalidError, 'provide input as keyword arguments' unless args.first.kind_of?(Hash)
      schema_result = self.class.schema.call(args.first)
      if schema_result.failure?
        raise InvalidError.new("Invalid command: #{schema_result.errors.to_h.to_s}", schema_result.errors)
      end

      super(schema_result.output)
    end

    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        hash[var.to_s.delete('@')] = instance_variable_get(var)
      end
    end

    def inspect
      "#{self.class}(#{to_h})"
    end

    class << self
      def configure_schema
        @schema ||= Dry::Schema.Params do
          config.validate_keys = true
          yield(self) if block_given?
        end
        set_attributes_from_schema
      end

      def schema
        @schema || configure_schema
      end
      # @return [Hash]
      # @example
      # class MyCommand < Infra::Command
      #  configure_schema do |config|
      #  config.required(:uuid).filled(:string)
      #  config.required(:registered_by).filled(:string)
      #  end
      #  end
      #  MyCommand.json_schema
      #  # => {"type"=>"object",
      #  #     "properties"=>{"uuid"=>{"type"=>"string"}, "registered_by"=>{"type"=>"string"}},
      #        "required"=>["uuid", "registered_by"]}
      def json_schema
        schema.json_schema
      end

      def set_attributes_from_schema
        schema.rules.keys.each { |name| attribute(name.to_sym) }
      end
    end

    # @raise [InvalidError] when the command is invalid
    # @return [void]
    # @example
    # class MyCommand < Infra::Command
    #   configure_schema do |config|
    #   config.required(:uuid).filled(:string)
    #   config.required(:registered_by).filled(:string)
    #  end
    # end
    # MyCommand.new
    # # => raises Infra::Command::InvalidError
    class InvalidError < StandardError
      attr_reader :errors

      def initialize(message, dry_schema_errors = {})
        super(message)
        @errors = dry_schema_errors.to_h
      end

      def full_messages
        return [] if errors.empty?

        errors.flat_map do |attribute, error_messages|
          error_messages.map do |error_message|
            "#{attribute} #{error_message}"
          end
        end
      end
    end
  end
end
