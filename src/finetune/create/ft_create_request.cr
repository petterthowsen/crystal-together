require "json"

module Together::Finetune::Create
  # Request to create a new fine-tuning job
  class Request < Together::Finetune::Request
    include JSON::Serializable

    property model : String
    property training_file : String
    property validation_file : String?
    property hyperparameters : HyperParameters?
    property command : String?
    property suffix : String?
    property wandb_api_key : String?

    def initialize(
      @model : String,
      @training_file : String,
      @validation_file : String? = nil,
      @hyperparameters : HyperParameters? = nil,
      @command : String? = nil,
      @suffix : String? = nil,
      @wandb_api_key : String? = nil
    )
    end

    def method : String
      "POST"
    end

    def endpoint : String
      "/fine-tunes"
    end

    def body : String?
      to_json
    end

    def query_params : Hash(String, String)?
      nil
    end
  end
end