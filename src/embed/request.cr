require "json"
require "../request"

module Together::Embed

  class Request < Together::Request
    include JSON::Serializable

    property input : String | Array(String)
    property model : String

    def initialize(
      @input : String | Array(String),
      @model : String
    )
    end

    def method : String
      "POST"
    end

    def endpoint : String
      "/embeddings"
    end

    def body : String?
      to_json
    end

    def query_params : Hash(String, String)?
      nil
    end
  end
end
