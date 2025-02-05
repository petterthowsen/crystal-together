require "json"
require "http/client"
require "uri"

require "./request"
require "./errors"
require "./chat/*"
require "./embed/*"
require "./finetune/*"
require "./finetune/create/*"
require "./audio/speech/*"

module Together

	# Main client class for interacting with Together.ai API
  class Client
    # Base URL for the Together.ai API
    BASE_URL = "https://api.together.xyz/v1"

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

    def speech(
      model : String,
      input : String,
      voice : String,
      response_format : String? = "wav",
      language : String? = "en",
      response_encoding : String? = "pcm_f32le",
      sample_rate : Int32? = 44100,
      stream : Bool? = false
    ) : Audio::Speech::Response
      request = Audio::Speech::Request.new(
        model: model,
        input: input,
        voice: voice,
        response_format: response_format,
        language: language,
        response_encoding: response_encoding,
        sample_rate: sample_rate,
        stream: stream
      )
      response = execute(request)
      Audio::Speech::Response.from_json(response.body)
    end

    # Execute a request
    def execute(request : Request)
      response = self.request(
        request.method,
        request.endpoint,
        request.body,
        request.query_params,
        request.headers
      )
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
    private def request(
      method : String,
      endpoint : String,
      body : String?,
      query_params : Hash(String, String)?,
      headers : Hash(String, String)
    ) : HTTP::Client::Response
      url = "#{BASE_URL}#{endpoint}"
      if query_params && !query_params.empty?
        url += "?#{HTTP::Params.encode(query_params)}"
      end

      headers = headers.merge({
        "Authorization" => "Bearer #{@api_key}"
      })

      HTTP::Client.exec(
        method: method,
        url: url,
        body: body,
        headers: HTTP::Headers.new.tap { |h|
          headers.each { |k, v| h[k] = v }
        }
      )
    end
  end
end