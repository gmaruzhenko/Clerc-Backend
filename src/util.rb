module Util

  # TODO use native Ruby logger instead
  def log_info(message)
    puts "\nINFO: " + message + "\n\n"
    message
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
      JWT.encode(payload, File.open(File.join(CERT_PATH, "clerc_jwt_fast.key")).read)
    end

    def self.decode(token)
      return JWT.decode(token, File.open(File.join(CERT_PATH, "clerc_jwt_fast.key")).read)[0]
    rescue
      'FAILED'
    end
  end

  # Returns 10 min JWT token for valid users
  def refresh_token (json_input , firestore)
    firestore_service = FirestoreService.new firestore
    userID = json_input['userID']
    if firestore_service.valid_user? userID
      return JsonWebToken.encode(json_input, Time.now.to_i + 600)
    else
      return_error 401, "Access denied - invalid user ID"
    end
  end
end
