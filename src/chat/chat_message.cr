module Together::Chat
    # Chat message structure
  struct Message
    include JSON::Serializable

    getter role : String
    getter content : String

    def initialize(@role : String, @content : String)
    end
  end
end