require_relative '../service/firestore_service'
require_relative 'endpoint_helper'
require_relative '../util'

module SecurityEndpoints
  include EndpointHelper
  include Util

  # Returns a JWT token with 60 second expiry time
  # If & only if the user is a valid customer or a valid vendor
  def refresh_token(json_input, firestore)
    # Check that the user ID is valid
    firestore_service = FirestoreService.new firestore
    input_user_id = json_input['user_id']
    # If valid, return a new JWT, else deny
    if firestore_service.valid_user? input_user_id
      return JsonWebToken.encode(json_input, Time.now.to_i + 60)
    else
      return_error 401, 'Access Denied - Invalid User ID'
    end
  end
end
