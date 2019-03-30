module EndpointHelper

  # Parse JSON parameters from incoming response
  # Or return 400 if the request JSON is invalid
  def parse_json_params
    JSON.parse(request.body.read)
  rescue StandardError
    halt 400, { message: 'Invalid JSON' }.to_json
  end

end