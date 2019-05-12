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
require_relative 'service/email_service'

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

# Initialize the base firestore service
firestore = Google::Cloud::Firestore.new project_id: 'paywithclerc-dev'
puts 'Firestore client initialized'

# Initialize our own abstraction service for firestore
firestore_service = FirestoreService.new firestore

# Get secrets
jwt_secret = firestore_service.get_secret FirestoreService::JWT_KEY_DOC
stripe_secret = firestore_service.get_secret FirestoreService::STRIPE_KEY_DOC
mailgun_secret = firestore_service.get_secret FirestoreService::MAILGUN_KEY_DOC

# Initialize Stripe
Stripe.api_key = stripe_secret

# Initialize email service
email_service = EmailService.new firestore_service, mailgun_secret

# Test endpoint to check if server is up
get '/' do
  status 200
  return log_info("Connection Successful\n")
end

# Create a JWT for a valid user that lasts 10 min
post '/jwt/refresh' do
  return create_refresh_token(parse_json_params, firestore_service, jwt_secret)
end

# Create a customer in our platform account
post '/customers/create' do
  return create_customer
end

# Creates ephemeral key for mobile client to grant permissions
post '/customers/create-ephemeral-key' do
  return create_ephemeral_key check_jwt(parse_json_params, jwt_secret)
end

# Sends a receipt email
post '/customers/email-receipt' do
  return send_receipt_email parse_json_params, email_service
end

# Creates a charge on a stripe connected account
post '/charge' do
  return charge(check_jwt(parse_json_params, jwt_secret),
                firestore_service)
end

# Connects a store to a vendor
post('/vendors/connect-standard-account') do
  return connect_standard_account(check_jwt(parse_json_params, jwt_secret),
                                  firestore_service,
                                  stripe_secret)
end

