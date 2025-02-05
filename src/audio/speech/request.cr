require "json"

module Together::Audio::Speech
  # Request to generate audio from text
  class Request < Together::Request
    include JSON::Serializable

    property model : String
    property input : String
    property voice : String
    property response_format : String?
    property language : String?
    property response_encoding : String?
    property sample_rate : Int32?
    property stream : Bool?

    def initialize(
      @model : String,
      input : String,
      @voice : String,
      @response_format : String? = "wav",
      @language : String? = "en",
      @response_encoding : String? = "pcm_f32le",
      @sample_rate : Int32? = 44100,
      @stream : Bool? = false
    )
      @input = input  # Make sure we set input
    end

    def method : String
      "POST"
    end

    def endpoint : String
      "/audio/speech"
    end

    def headers : Hash(String, String)
      super.merge({
        "Accept" => "application/octet-stream",
        "Content-Type" => "application/json"
      })
    end

    def body : String?
      to_json
    end

    def query_params : Hash(String, String)?
      nil
    end
  end
end
