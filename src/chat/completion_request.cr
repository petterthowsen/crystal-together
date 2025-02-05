require "json"

module Together::Chat

    # Chat completion request
  @[JSON::Serializable::Options(emit_nulls: true)]
  class CompletionRequest < Request
    include JSON::Serializable

    property messages : Array(Message)
    property model : String
    property temperature : Float64?
    property top_p : Float64?
    property n : Int32?
    property max_tokens : Int32?
    property stop : Array(String)?
    property stream : Bool?

    def initialize(
      @messages : Array(Message),
      @model : String,
      @temperature : Float64? = nil,
      @top_p : Float64? = nil,
      @n : Int32? = nil,
      @max_tokens : Int32? = nil,
      @stop : Array(String)? = nil,
      @stream : Bool? = nil
    )
    end

    def method : String
      "POST"
    end

    def endpoint : String
      "/chat/completions"
    end

    def body : String?
      to_json
    end

    def to_s
      to_pretty_json
    end

    def query_params : Hash(String, String)?
      nil
    end
  end
end