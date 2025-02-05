module Together
    # Base class for all API requests
  abstract class Request
    abstract def method : String
    abstract def endpoint : String
    abstract def body : String?
    abstract def query_params : Hash(String, String)?
  end
end