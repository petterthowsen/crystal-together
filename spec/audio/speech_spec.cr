require "../spec_helper"

API_KEY = File.read("#{__DIR__}/../api_key.txt").strip

describe Together::Audio::Speech::Request do
  it "creates a request with required parameters" do
    request = Together::Audio::Speech::Request.new(
      model: "cartesia/sonic",
      input: "Hello, world!",
      voice: "laidback woman"
    )

    request.method.should eq("POST")
    request.endpoint.should eq("/audio/speech")
    request.query_params.should be_nil
    request.headers["Accept"].should eq("application/octet-stream")
    request.headers["Content-Type"].should eq("application/json")

    body = request.body.not_nil!
    body.should contain(%("model":"cartesia/sonic"))
    body.should contain(%("input":"Hello, world!"))
    body.should contain(%("voice":"laidback woman"))
    body.should contain(%("response_format":"wav"))
    body.should contain(%("language":"en"))
    body.should contain(%("response_encoding":"pcm_f32le"))
    body.should contain(%("sample_rate":44100))
    body.should contain(%("stream":false))
  end

  it "creates a request with all parameters" do
    request = Together::Audio::Speech::Request.new(
      model: "cartesia/sonic",
      input: "Hello, world!",
      voice: "laidback woman",
      response_format: "mp3",
      language: "fr",
      response_encoding: "pcm_s16le",
      sample_rate: 48000,
      stream: true
    )

    body = request.body.not_nil!
    body.should contain(%("voice":"laidback woman"))
    body.should contain(%("response_format":"mp3"))
    body.should contain(%("language":"fr"))
    body.should contain(%("response_encoding":"pcm_s16le"))
    body.should contain(%("sample_rate":48000))
    body.should contain(%("stream":true))
  end
end

describe Together::Client do
  client = Together::Client.new(API_KEY)

  it "generates speech from text" do
    response = client.speech(
      model: "cartesia/sonic",
      input: "Hello, world!",
      voice: "laidback woman"
    )

    response.audio.should_not be_empty
  end

  it "raises ClientError with invalid model" do
    expect_raises(Together::ClientError) do
      client.speech(
        model: "invalid-model",
        input: "Hello, world!",
        voice: "laidback woman"
      )
    end
  end
end
