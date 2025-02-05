require "./spec_helper"

API_KEY = File.read("#{__DIR__}/api_key.txt").strip

describe Together::Chat::Message do
  it "creates a chat message with role and content" do
    message = Together::Chat::Message.new(role: "user", content: "Hello!")
    message.role.should eq("user")
    message.content.should eq("Hello!")
  end

  it "serializes to JSON correctly" do
    message = Together::Chat::Message.new(role: "system", content: "You are a helpful assistant.")
    json = message.to_json
    json.should contain(%({"role":"system","content":"You are a helpful assistant."}))
  end
end

describe Together::Chat::CompletionRequest do
  it "creates a request with required parameters" do
    messages = [Together::Chat::Message.new(role: "user", content: "Hello!")]
    request = Together::Chat::CompletionRequest.new(
      messages: messages,
      model: "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo"
    )

    request.method.should eq("POST")
    request.endpoint.should eq("/chat/completions")
    request.query_params.should be_nil

    body = request.body.not_nil!
    body.should contain(%("messages":[{"role":"user","content":"Hello!"}]))
    body.should contain(%("model":"meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo"))
  end

  it "creates a request with optional parameters" do
    messages = [Together::Chat::Message.new(role: "user", content: "Hello!")]
    request = Together::Chat::CompletionRequest.new(
      messages: messages,
      model: "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
      temperature: 0.7,
      top_p: 0.9,
      n: 1,
      max_tokens: 100,
      stop: ["END"],
      stream: false
    )

    body = request.body.not_nil!
    body.should contain(%("temperature":0.7))
    body.should contain(%("top_p":0.9))
    body.should contain(%("n":1))
    body.should contain(%("max_tokens":100))
    body.should contain(%("stop":["END"]))
    body.should contain(%("stream":false))
  end
end

describe Together::Client do
  client = Together::Client.new(API_KEY)

  it "performs a chat completion request" do
    messages = [
      Together::Chat::Message.new(role: "system", content: "You are a helpful assistant."),
      Together::Chat::Message.new(role: "user", content: "Say hello!")
    ]

    response = client.chat_completion(
      messages: messages,
      model: "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
      temperature: 0.7,
      max_tokens: 50
    )

    response.id.should_not be_empty
    response.object.should eq("chat.completion")
    response.model.should contain("meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo")
    response.choices.size.should eq(1)
    response.choices[0].message.role.should eq("assistant")
    response.choices[0].message.content.should_not be_empty
    response.usage.total_tokens.should be > 0
  end

  it "raises AuthenticationError with invalid API key" do
    invalid_client = Together::Client.new("invalid-api-key")
    messages = [Together::Chat::Message.new(role: "user", content: "Hello!")]

    expect_raises(Together::AuthenticationError) do
      invalid_client.chat_completion(
        messages: messages,
        model: "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo"
      )
    end
  end

  it "raises ClientError with invalid model" do
    messages = [Together::Chat::Message.new(role: "user", content: "Hello!")]

    expect_raises(Together::ClientError) do
      client.chat_completion(
        messages: messages,
        model: "invalid-model"
      )
    end
  end
end
