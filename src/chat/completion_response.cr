module Together::Chat
    # Chat completion response choice
  struct CompletionChoice
    include JSON::Serializable

    getter message : Message
    getter finish_reason : String?
    getter index : Int32
  end

  # Chat completion usage information
  struct CompletionUsage
    include JSON::Serializable

    getter prompt_tokens : Int32
    getter completion_tokens : Int32
    getter total_tokens : Int32
  end

  # Chat completion response
  struct CompletionResponse
    include JSON::Serializable

    getter id : String
    getter object : String
    getter created : Int64
    getter model : String
    getter choices : Array(CompletionChoice)
    getter usage : CompletionUsage
  end
end