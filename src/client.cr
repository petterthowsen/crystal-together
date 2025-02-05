require "json"
require "http/client"
require "uri"

require "./request"
require "./errors"
require "./chat/*"
require "./embed/*"
require "./finetune/*"
require "./finetune/create/*"

module Together

	# Main client class for interacting with Together.ai API
  class Client
    BASE_URL = "https://api.together.ai/v1"

    property api_key : String

    def initialize(@api_key : String)
    end

    # Create a chat completion
    def chat_completion(messages : Array(Chat::Message), model : String, **options) : Chat::CompletionResponse
      request = Chat::CompletionRequest.new(
        messages: messages,
        model: model,
        temperature: options[:temperature]?.try(&.to_f64),
        top_p: options[:top_p]?.try(&.to_f64),
        n: options[:n]?.try(&.to_i32),
        max_tokens: options[:max_tokens]?.try(&.to_i32),
        stop: options[:stop]?.try(&.as(Array(String))),
        stream: options[:stream]?.try(&.as(Bool))
      )

      chat_completion(request)
    end

    def chat_completion(request : Chat::CompletionRequest)
      response = execute(request)
      Chat::CompletionResponse.from_json(response.body)
    end

    # Create embeddings for a text or array of texts
    def embedding(input : String | Array(String), model : String) : Embed::Response
      request = Embed::Request.new(input: input, model: model)
      response = execute(request)
      Embed::Response.from_json(response.body)
    end

    def create_finetune(
      model : String,
      training_file : String,
      validation_file : String? = nil,
      hyperparameters : Finetune::HyperParameters? = nil,
      command : String? = nil,
      suffix : String? = nil,
      wandb_api_key : String? = nil
    ) : Finetune::Create::Response
      request = Finetune::Create::Request.new(
        model: model,
        training_file: training_file,
        validation_file: validation_file,
        hyperparameters: hyperparameters,
        command: command,
        suffix: suffix,
        wandb_api_key: wandb_api_key
      )
      response = execute(request)
      Finetune::Create::Response.from_json(response.body)
    end

    # Execute a request
    def execute(request : Request)
      response = self.request(request.method, request.endpoint, request.body, request.query_params)
      handle_response(response)
    end

    # Handle API response
    private def handle_response(response : HTTP::Client::Response)
      case response.status_code
      when 200..299
        response
      when 401, 403
        raise AuthenticationError.new(response)
      when 400..499
        raise ClientError.new(response)
      when 500..599
        raise ServerError.new(response)
      else
        raise Error.new("Unexpected response status: #{response.status_code}")
      end
    end

    # Send a request to the Together.ai API
    private def request(method : String, endpoint : String, body : String? = nil, query_params : Hash(String, String)? = nil)
      method = method.upcase

      # Build headers
      headers = HTTP::Headers.new
      headers["Authorization"] = "Bearer #{@api_key}"
      headers["Content-Type"] = "application/json"
      
      # Build URL with query parameters
      uri = URI.parse("#{BASE_URL}#{endpoint}")
      if query_params && !query_params.empty?
        uri.query = URI::Params.encode(query_params)
      end

      HTTP::Client.new(uri) do |client|
        client.exec(method, uri.request_target, headers: headers, body: body)
      end
    end
  end
end