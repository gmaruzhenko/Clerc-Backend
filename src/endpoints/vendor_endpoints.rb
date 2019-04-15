require_relative 'endpoint_helper'
require_relative '../util'
require_relative '../service/firestore_service'
require 'dotenv'

# Module to hold logic for all vendor related endpoints
module VendorEndpoints

  include EndpointHelper
  include Util

  STRIPE_API_SECRET = Stripe.api_key # Should be initialized in server.rb
  STRIPE_CONNECTED_ACCT_URL = 'https://connect.stripe.com/oauth/token'.freeze

  DEFAULT_TXN_FEE_BASE = 0.0
  DEFAULT_TXN_FEE_PERCENT = 0.0
  DEFAULT_CURRENCY = 'cad'.freeze

  #
  # Connects a standard stripe retailer account with our system
  #
  def connect_standard_account(json_input, firestore)
    # Get the firebase service
    firestore_service = FirestoreService.new firestore

    # Check that it's not empty, otherwise continue
    halt 400, 'Invalid request - no JSON given' if json_input.empty?

    new_account_auth = json_input['account_auth_code']
    vendor_id = json_input['vendor_id']
    new_store_name = json_input['store_name']

    # Check that parameters are given
    halt 400, 'Invalid request - missing fields' if
        new_account_auth.nil? || new_store_name.nil?

    # Retrieve required fields from Stripe
    stripe_data = {
      client_secret: STRIPE_API_SECRET,
      code: new_account_auth,
      grant_type: 'authorization_code'
    }

    # DEBUGGING ONLY
    # puts "Data passed to stripe: #{stripe_data.to_json}"

    # Make request to Stripe
    stripe_response = HTTP.post(STRIPE_CONNECTED_ACCT_URL,
                                form: stripe_data)

    # DEBUGGING ONLY
    # log_info "Stripe response body: #{stripe_response.body}"

    # Check that we have a returned success
    return_error 400, 'API Call to Stripe Failed' if stripe_response.code != 200

    # Response is valid, store information specific to the retailer in firestore
    stripe_response_body = JSON.parse(stripe_response.body)
    store_pub_key = stripe_response_body['stripe_publishable_key']
    store_user_id = stripe_response_body['stripe_user_id']
    store_refresh_token = stripe_response_body['refresh_token']
    store_access_token = stripe_response_body['access_token']
    # Construct the vendor object
    new_store = Store.new(nil, new_store_name, store_pub_key,
                          store_user_id, store_refresh_token, store_access_token,
                          DEFAULT_TXN_FEE_BASE, DEFAULT_TXN_FEE_PERCENT, DEFAULT_CURRENCY)
    # Save the new vendor to firebase
    firebase_id = firestore_service.save_store new_store, vendor_id

    log_info 'Success in creating standard account!'

    # Return the firebase ID
    status 201
    { firebase_id: firebase_id }.to_json
  end
end
