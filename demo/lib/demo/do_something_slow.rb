module Demo
  class DoSomethingSlow < Infra::Command
    configure_schema do |config|
      config.required(:uuid).filled(:string)
    end

    alias :aggregate_id :uuid
  end
end