#
#   Created by Georgiy Maruzhenko on 2019-03-16.
#   Copyright © 2019 Georgiy Maruzhenko. All rights reserved.
#
require 'sinatra'
require 'stripe'
require 'json'
require 'http'
require 'google/cloud/firestore'

require_relative 'model/store'
require_relative 'endpoints/customer_endpoints'
require_relative 'endpoints/endpoint_helper'
require_relative 'endpoints/vendor_endpoints'
require_relative 'endpoints/security_endpoints'
require_relative 'service/firestore_service'

# Include the modules that we need
include EndpointHelper
include CustomerEndpoints
include VendorEndpoints
include SecurityEndpoints
include Util

# CORS
require 'sinatra/cors'
set :allow_origin, '*'
set :allow_methods, 'GET,POST'
set :allow_headers, 'content-type,access-control-allow-origin'

# Load environment variables for development
# You can download the required .env file from Google Drive. See README
# TODO: COMMENT OUT FOR DEPLOYMENT
# require 'dotenv'
# Dotenv.load
# STRIPE_API_SECRET = ENV['STRIPE_API_SECRET']

FIREBASE_PROJ_ID = 'paywithclerc'.freeze
STRIPE_API_SECRET = 'sk_test_dsoNrcwd0QnNHt8znIVNpCJK'.freeze

Stripe.api_key = STRIPE_API_SECRET

firestore = Google::Cloud::Firestore.new project_id: FIREBASE_PROJ_ID
puts 'Firestore client initialized'

# Test endpoint to check if server is up
get '/' do
  status 200
  return log_info("Connection Successful\n")
end

# Create a JWT for a valid user that lasts 10 min
post '/jwt/refresh' do
  return create_refresh_token(parse_json_params, firestore)
end

# Create a customer in our platform account
post '/customers/create' do
  check_jwt parse_json_params
  return create_customer
end

# Creates ephemeral key for mobile client to grant permissions
post '/customers/create-ephemeral-key' do
  return create_ephemeral_key check_jwt(parse_json_params)
end

# Creates a charge on a stripe connected account
post '/charge' do
  return charge(check_jwt(parse_json_params), firestore)
end

# Connects a store to a vendor
post('/vendors/connect-standard-account') do
  return connect_standard_account(check_jwt(parse_json_params), firestore)
end

