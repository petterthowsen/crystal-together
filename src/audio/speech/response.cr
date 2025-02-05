require "json"

module Together::Audio::Speech
  # Response from generating audio
  struct Response
    include JSON::Serializable

    getter audio : String  # Base64 encoded audio data
  end
end
