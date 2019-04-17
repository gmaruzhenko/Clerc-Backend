module EndpointHelper

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
  def jwt_handler(jwt_input)
    json_decoded = JsonWebToken.decode(jwt_input['token'])
    exp = json_decoded['exp']
    puts exp
    if exp.nil?
      return_error 401, "token expired , request new token at /refresh"
    else
      return jwt_input
    end
  end

  # encrypt / decrypt tokens
  class JsonWebToken
    JWT_SECRET_PATH = Dir.pwd

    def self.encode(payload, expiration)
      payload[:exp] = expiration
      JWT.encode(payload, File.open(File.join(JWT_SECRET_PATH, "clerc_jwt_fast.key")).read)
    end

    def self.decode(token)
      return JWT.decode(token, File.open(File.join(JWT_SECRET_PATH, "clerc_jwt_fast.key")).read)[0]
    rescue
      'FAILED'
    end
  end

end