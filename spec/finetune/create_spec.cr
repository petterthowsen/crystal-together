require "../spec_helper"

API_KEY = File.read("#{__DIR__}/../api_key.txt").strip

describe Together::Finetune::Create::Request do
  it "creates a request with required parameters" do
    request = Together::Finetune::Create::Request.new(
      model: "mistralai/Mistral-7B-v0.1",
      training_file: "path/to/training.jsonl"
    )

    request.method.should eq("POST")
    request.endpoint.should eq("/fine-tunes")
    request.query_params.should be_nil

    body = request.body.not_nil!
    body.should contain(%("model":"mistralai/Mistral-7B-v0.1"))
    body.should contain(%("training_file":"path/to/training.jsonl"))
  end

  it "creates a request with all parameters" do
    hyperparameters = Together::Finetune::HyperParameters.new(
      batch_size: 4,
      epochs: 3,
      learning_rate: 0.0002,
      warmup_ratio: 0.1
    )

    request = Together::Finetune::Create::Request.new(
      model: "mistralai/Mistral-7B-v0.1",
      training_file: "path/to/training.jsonl",
      validation_file: "path/to/validation.jsonl",
      hyperparameters: hyperparameters,
      command: "custom command",
      suffix: "my-custom-model",
      wandb_api_key: "test-key"
    )

    body = request.body.not_nil!
    body.should contain(%("validation_file":"path/to/validation.jsonl"))
    body.should contain(%("batch_size":4))
    body.should contain(%("epochs":3))
    body.should contain(%("learning_rate":0.0002))
    body.should contain(%("warmup_ratio":0.1))
    body.should contain(%("command":"custom command"))
    body.should contain(%("suffix":"my-custom-model"))
    body.should contain(%("wandb_api_key":"test-key"))
  end
end

describe Together::Client do
  client = Together::Client.new(API_KEY)

  it "creates a fine-tuning job" do
    # Note: This test requires actual files to be uploaded first
    pending "requires actual training file to be uploaded"
  end

  it "raises ClientError with invalid model" do
    expect_raises(Together::ClientError) do
      client.create_finetune(
        model: "invalid-model",
        training_file: "path/to/training.jsonl"
      )
    end
  end
end
