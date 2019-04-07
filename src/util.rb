module Util

  # TODO use native Ruby logger instead
  def log_info(message)
    puts "\nINFO: " + message + "\n\n"
    message
  end

  class JsonWebToken
    def self.encode(payload, expiration)
      payload[:exp] = expiration
      JWT.encode(payload, 'SECRET')
    end

    def self.decode(token)
      return JWT.decode(token, 'SECRET')[0]
    rescue
      'FAILED'
    end
  end

end