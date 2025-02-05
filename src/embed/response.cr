require "json"

module Together
  module Embed
    struct EmbeddingData
      include JSON::Serializable

      getter object : String
      getter embedding : Array(Float64)
      getter index : Int32
    end

    struct Response
      include JSON::Serializable

      getter data : Array(EmbeddingData)
      getter model : String
      getter object : String
    end
  end
end