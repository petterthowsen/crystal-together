module Together
	# Base error class for all Together.ai errors
	class Error < Exception; end

	# Raised when the API returns a 4xx error
	class ClientError < Error
		getter response : HTTP::Client::Response

		def initialize(@response)
			message = "HTTP #{@response.status_code}"
			if body = @response.body
				message += "\nBody: #{body}"
			end
			message += "\nHeaders: #{@response.headers.inspect}"
			super(message)
		end
	end

	# Raised when the API returns a 5xx error
	class ServerError < Error
		getter response : HTTP::Client::Response

		def initialize(@response)
			super("HTTP #{@response.status_code}: #{@response.body}")
		end
	end

	# Raised when the API returns an unexpected content type
	class ContentTypeError < Error; end

	# Raised when the API key is invalid or missing
	class AuthenticationError < ClientError; end
end