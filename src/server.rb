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
require '../src/Functions/customerMethods'
require '../src/Functions/helperFunctions'
require '../src/Functions/vendorMethods'

include HelperFunctions
include CustomerMethods
include VendorMethods
# Load environment variables for development (comment out in Prod)
# You can download the required .env file from Google Drive. See README
require 'dotenv'
Dotenv.load

# Loading environment variables will likely look very different in EC2
FIREBASE_PROJ_ID = ENV['FIREBASE_PROJ_ID']
STRIPE_API_SECRET = ENV['STRIPE_API_SECRET']
STRIPE_CONNECTED_ACCT_URL = 'https://connect.stripe.com/oauth/token'.freeze
Stripe.api_key = STRIPE_API_SECRET

firestore = Google::Cloud::Firestore.new project_id: FIREBASE_PROJ_ID
puts 'Firestore client initialized'

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
  return connectStandardAccount(json_params , firestore)
end
