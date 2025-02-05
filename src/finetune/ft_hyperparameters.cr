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
end