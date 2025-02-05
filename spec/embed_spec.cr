require "./spec_helper"

API_KEY = File.read("#{__DIR__}/api_key.txt").strip

describe Together::Embed::Request do
  it "creates a request with a single input" do
    request = Together::Embed::Request.new(
      input: "Hello, world!",
      model: "BAAI/bge-large-en-v1.5"
    )

    request.method.should eq("POST")
    request.endpoint.should eq("/embeddings")
    request.query_params.should be_nil

    body = request.body.not_nil!
    body.should contain(%("input":"Hello, world!"))
    body.should contain(%("model":"BAAI/bge-large-en-v1.5"))
  end

  it "creates a request with multiple inputs" do
    inputs = ["Hello, world!", "How are you?"]
    request = Together::Embed::Request.new(
      input: inputs,
      model: "BAAI/bge-large-en-v1.5"
    )

    body = request.body.not_nil!
    body.should contain(%("input":["Hello, world!","How are you?"]))
  end
end

describe Together::Client do
  client = Together::Client.new(API_KEY)

  it "creates embeddings for a single input" do
    response = client.embedding(
      input: "Hello, world!",
      model: "BAAI/bge-large-en-v1.5"
    )

    response.object.should eq("list")
    response.model.should eq("BAAI/bge-large-en-v1.5")
    response.data.size.should eq(1)
    response.data[0].object.should eq("embedding")
    response.data[0].embedding.size.should be > 0
    response.data[0].index.should eq(0)
  end

  it "creates embeddings for multiple inputs" do
    inputs = ["Hello, world!", "How are you?"]
    response = client.embedding(
      input: inputs,
      model: "BAAI/bge-large-en-v1.5"
    )

    response.object.should eq("list")
    response.model.should eq("BAAI/bge-large-en-v1.5")
    response.data.size.should eq(2)
    response.data[0].object.should eq("embedding")
    response.data[1].object.should eq("embedding")
    response.data[0].embedding.size.should be > 0
    response.data[1].embedding.size.should be > 0
    response.data[0].index.should eq(0)
    response.data[1].index.should eq(1)
  end

  it "raises ClientError with invalid model" do
    expect_raises(Together::ClientError) do
      client.embedding(
        input: "Hello, world!",
        model: "invalid-model"
      )
    end
  end
end
