module HelperFunctions

  # JSON Parameter parser for incoming response body
  def json_params
    JSON.parse(request.body.read)
  rescue StandardError
    halt 400, { message: 'Invalid JSON' }.to_json
  end

  # Logging
  def log_info(message)
    puts "\nINFO: " + message + "\n\n"
    message
  end

end