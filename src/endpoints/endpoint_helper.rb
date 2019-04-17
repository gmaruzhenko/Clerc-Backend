require 'jwt'

# Helper methods for all our endpoints
module EndpointHelper
  # TODO: COMMENT OUT FOR DEPLOYMENT
  require 'dotenv'
  Dotenv.load

  JWT_KEY = ENV['JWT_KEY']

  # Parse JSON parameters from incoming response
  # Or return 400 if the request JSON is invalid
  def parse_json_params
    JSON.parse(request.body.read)
  rescue StandardError
    halt 400, { message: 'Invalid JSON' }.to_json
  end

  # Returns an error with the status code & message
  def return_error(status_code, msg)
    halt status_code, {
      error: msg
    }.to_json
  end

  # Returns input parameters if token is valid
  # Else will return a 401 error code
  def check_jwt(jwt_input)

    # Decode the token - this will automatically check for expiry
    begin
      jwt_token = decode_jwt jwt_input['token']
      puts jwt_token
      # Also check that an expiry was actually given
      exp = jwt_token[0]['exp'] # The first in the array is the token
      if exp.nil?
        return error 401, 'Invalid JWT - no expiry'
      end
    rescue JWT::ExpiredSignature
      # Token has expired
      return error 401, 'JWT has expired. Please request a new one'
    end

    # If all checks pass - return the original input
    jwt_input
  end

  # Creates a new JWT token
  def create_jwt(sub, exp)
    payload = {
      sub: sub,
      exp: exp
    }
    JWT.encode payload, JWT_KEY, 'HS256'
  end

  # Decodes a given JWT key
  # THROWS JWT::ExpiredSignature if the JWT has expired
  def decode_jwt(jwt)
    JWT.decode jwt, JWT_KEY, true, algorithm: 'HS256'
  end

end
