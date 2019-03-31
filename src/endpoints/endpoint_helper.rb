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

end