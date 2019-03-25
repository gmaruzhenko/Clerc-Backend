#
#   Created by Georgiy Maruzhenko on 2019-03-16.
#   Copyright © 2019 Georgiy Maruzhenko. All rights reserved.
#
require 'sinatra'
require 'stripe'
require 'json'
require 'http'
require 'google/cloud/firestore'
require '../src/Model/Vendor'
require '../src/Service/firestore'
require '../src/Functions/endpointMethods'
require '../src/Functions/helperFunctions'

include EndpointMethods
include HelperFunctions

# Load environment variables for development (comment out in Prod)
# You can download the required .env file from Google Drive. See README
require 'dotenv'
Dotenv.load

# Loading environment variables will likely look very different in EC2
FIREBASE_PROJ_ID = ENV['FIREBASE_PROJ_ID']
STRIPE_API_SECRET = ENV['STRIPE_API_SECRET']
STRIPE_CONNECTED_ACCT_URL = 'https://connect.stripe.com/oauth/token'.freeze
Stripe.api_key = STRIPE_API_SECRET

# Our secret api key for logging customers in our account (comment to switch accounts during debugging)
# Account name = Test1
# Stripe.api_key = "sk_test_dUndr7GHsaxgYD9o9jxn6Kmy"
# Account name = Sample
# Stripe.api_key = "sk_test_dsoNrcwd0QnNHt8znIVNpCJK"

# configure to run as server
# for local testing comment out line below
# set :bind, '0.0.0.0'
#
# CORS
configure do
  enable :cross_origin
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

firestore = Google::Cloud::Firestore.new project_id: FIREBASE_PROJ_ID
puts 'Firestore client initialized'


# Test endpoint to check if server is up
get '/' do
  status 200
  return log_info("Connection Successful\n")
end

# Create a customer in our platform account
# @param = nil
# @return = json stripe customer object
get '/customers/create' do
  return createCustomer
end

# generates temp key for ios
# @param = stripe_version
# @param = customer_id
# @return = json stripe ephemeral key object
post '/customers/create-ephemeral-key' do
  return createEphemeralKey (json_params)
end

# Creates a charge on a stripe connected account
# @param = customer_id
# @param = CONNECTED_STRIPE_ACCOUNT_ID
# @param = amount
# @param = source
# @return = stripe charge id
post '/charge' do
  return charge(json_params)
end

# This is called by front-end once the connected account is authorized
# Once the business gives us authorization, frontend will receive a code
# which is then passed to this method through a backend call.
# We will use the AUTHORIZATION_CODE to retrieve credentials for the business
# @param = account_auth_code
# @param = vendor_name
post('/vendors/connect-standard-account') do

  # Get params
  json_received = json_params

  # Check that it's not empty, otherwise continue
  halt 400, 'Invalid request - no JSON given' if json_received.empty?

  new_account_auth = json_received['account_auth_code']
  new_account_name = json_received['vendor_name']

  # Check that parameters are given
  halt 400, 'Invalid request - missing fields' if
    new_account_auth.nil? || new_account_name.nil?

  # Retrieve required fields from Stripe
  stripe_data = {
    client_secret: STRIPE_API_SECRET,
    code: new_account_auth,
    grant_type: 'authorization_code'
  }

  # DEBUGGING ONLY TODO REMOVE IN PROD
  log_info "Data passed to stripe: #{stripe_data.to_json}"

  # Make request to Stripe
  stripe_response = HTTP.post(STRIPE_CONNECTED_ACCT_URL,
                              form: stripe_data)

  # DEBUGGING ONLY TODO REMOVE IN PROD
  log_info "Stripe response body: #{stripe_response.body}"

  # Check that we have a returned success
  halt 400, 'Stripe call was unsuccessful. Please check input parameters' if stripe_response.code != 200

  # Response is valid, store information specific to the retailer in firestore
  stripe_response_body = JSON.parse(stripe_response.body)
  vendor_pub_key = stripe_response_body['stripe_publishable_key']
  vendor_user_id = stripe_response_body['stripe_user_id']
  vendor_refresh_token = stripe_response_body['refresh_token']
  vendor_access_token = stripe_response_body['access_token']
  # Construct the vendor object
  new_vendor = Vendor.new(nil, new_account_name, vendor_pub_key,
                          vendor_user_id, vendor_refresh_token, vendor_access_token)
  # Save the new vendor to firebase
  firebase_id = Firestore.save_vendor new_vendor, firestore

  log_info('Success in creating standard account!')

  # Return the firebase ID
  status 201
  { firebase_id: firebase_id }.to_json

end
