#
#   Created by Georgiy Maruzhenko on 2019-03-16.
#   Copyright © 2019 Georgiy Maruzhenko. All rights reserved.
#
require 'sinatra'
require 'stripe'
require 'json'
require 'http'
require 'google/cloud/firestore'
require 'jwt'
require_relative 'model/vendor'
require_relative 'endpoints/customer_endpoints'
require_relative 'endpoints/endpoint_helper'
require_relative 'endpoints/vendor_endpoints'


require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'



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

options '*' do
  response.headers['Allow'] = 'GET, PUT, POST, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token'
  response.headers['Access-Control-Allow-Origin'] = '*'
  200
end

class ClercServer  < Sinatra::Base

  # Load environment variables for development (comment out in Prod)
  # You can download the required .env file from Google Drive. See README
  require 'dotenv'
  Dotenv.load



  include EndpointHelper
  include CustomerEndpoints
  include VendorEndpoints
  include Util

# Loading environment variables will likely look very different in EC2
  FIREBASE_PROJ_ID = ENV['FIREBASE_PROJ_ID']
  STRIPE_API_SECRET = ENV['STRIPE_API_SECRET']
  STRIPE_CONNECTED_ACCT_URL = 'https://connect.stripe.com/oauth/token'.freeze


  Stripe.api_key = STRIPE_API_SECRET


  firestore = Google::Cloud::Firestore.new project_id: FIREBASE_PROJ_ID
  puts 'Firestore client initialized'

# Test endpoint to check if server is up
  get '/' do
    status 200
    return log_info("Connection Successful\n")
  end

  post '/jwt/generate' do
    # expire 30 sec from now
    token = JsonWebToken.encode(parse_json_params, Time.now.to_i + 3600)
    return token.to_json
  end

  post '/jwt/validate' do
    json_input = parse_json_params
    puts json_input
    token = json_input['token']
    decoded_jwt = JsonWebToken.decode(token)
    puts decoded_jwt.to_s
    return decoded_jwt.to_json
  end


  post '/jwt/refresh' do
    json_input = parse_json_params
    puts json_input

  end

# Create a customer in our platform account
# @param = nil
# @return = json stripe customer object
  get '/customers/create' do
    return create_customer
  end

# generates temp key for ios
# @param = stripe_version
# @param = customer_id
# @return = json stripe ephemeral key object
  post '/customers/create-ephemeral-key' do
    return create_ephemeral_key jwt_handler(parse_json_params)
  end

# Creates a charge on a stripe connected account
# @param = customer_id
# @param = CONNECTED_STRIPE_ACCOUNT_ID
# @param = amount
# @param = source
# @return = stripe charge id
  post '/charge' do
    return charge(jwt_handler(parse_json_params), firestore)
  end

# This is called by front-end once the connected account is authorized
# Once the business gives us authorization, frontend will receive a code
# which is then passed to this method through a backend call.
# We will use the AUTHORIZATION_CODE to retrieve credentials for the business
# @param = account_auth_code
# @param = vendor_name
  post('/vendors/connect-standard-account') do
    return connect_standard_account(jwt_handler(parse_json_params), firestore)
  end
end

#Place key and cert in the directory of this script
CERT_PATH = Dir.pwd

webrick_options = {
    :Port               => 4000,
    :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
    :DocumentRoot       => "/src/documents",
    :SSLEnable          => true,
    :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
    :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "localhost.cert")).read),
    :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "localhost.key")).read),
    :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ],
    :app                => ClercServer

}

Rack::Server.start webrick_options
