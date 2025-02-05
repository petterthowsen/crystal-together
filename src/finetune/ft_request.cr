require "../request"

module Together::Finetune
  # Represents a hyperparameter configuration for fine-tuning
  struct HyperParameters
    include JSON::Serializable

    property batch_size : Int32?
    property epochs : Int32?
    property learning_rate : Float64?
    property warmup_ratio : Float64?
    property lora_alpha : Int32?
    property lora_dropout : Float64?
    property lora_r : Int32?

    def initialize(
      @batch_size = nil,
      @epochs = nil,
      @learning_rate = nil,
      @warmup_ratio = nil,
      @lora_alpha = nil,
      @lora_dropout = nil,
      @lora_r = nil
    )
    end
  end

  # Represents a fine-tuning job request
  class Request < Together::Request
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
      params = {
        "model" => @model,
        "training_file" => @training_file,
      }

      if @validation_file
        params["validation_file"] = @validation_file
      end

      if @hyperparameters
        params["hyperparameters"] = @hyperparameters
      end

      if @command
        params["command"] = @command
      end

      if @suffix
        params["suffix"] = @suffix
      end

      if @wandb_api_key
        params["wandb_api_key"] = @wandb_api_key
      end

      params.to_json
    end

    def query_params : Hash(String, String)?
      nil
    end
  end
end