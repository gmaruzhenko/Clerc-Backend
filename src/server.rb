#
#   Created by Georgiy Maruzhenko on 2019-03-16.
#   Copyright © 2019 Georgiy Maruzhenko. All rights reserved.
#
require 'sinatra'
require 'stripe'
require 'json'
require 'http'

FIREBASE_PROJ_ID = 'paywithclerc'.freeze # TODO: this should be an environment variable
STRIPE_API_SECRET = 'sk_test_dsoNrcwd0QnNHt8znIVNpCJK'.freeze # TODO: this should also be an environment variable - use "dotenv" gem
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

helpers do
  # Json parser with error check
  def json_params
    JSON.parse(request.body.read)
  rescue StandardError
    halt 400, { message: 'Invalid JSON' }.to_json
  end

  # send log info to console for debugging
  def log_info(message)
    puts "\nINFO:" + message + "\n\n"
    message
  end
end

# Test endpoint to check if server is up
get '/' do
  status 200
  return log_info("Connection Successful\n")
end

# Create a customer in our platform account
get '/make_customer' do
  customer = Stripe::Customer.create(
    source: 'tok_mastercard' # obtained with Stripe.js
  )
  status 201 # successful in creating a stripe customer
  return log_info(customer[:id] + "\n")
end

# Creates a charge on a stripe connected account
post '/charge' do
  json_received = json_params

  token = Stripe::Token.create({
                                 customer: json_received['customer_id']
                               }, stripe_account: json_received['CONNECTED_STRIPE_ACCOUNT_ID'])

  charge = Stripe::Charge.create({
                                   amount: json_received['amount'],
                                   currency: 'cad',
                                   source: token.id,
                                   application_fee_amount: 123
                                 }, stripe_account: json_received['CONNECTED_STRIPE_ACCOUNT_ID'])
  status 201
end

# This is called by front-end once the connected account is authorized
# Once the business gives us authorization, frontend will receive an AUTHORIZATION_CODE
# which is then passed to this method. We will use the AUTHORIZATION_CODE to retrieve credentials for the business
post '/create-standard-account' do
  # Get the authorization code & cast to string
  json_input = json_params

  # Check that it's not empty, otherwise continue
  halt 400, 'Invalid request' if json_input.empty?

  # Retrieve required fields from Stripe
  # Required data to pass
  stripe_data = {
    client_secret: STRIPE_API_SECRET,
    code: json_input['account_auth_code'],
    grant_type: 'authorization_code'
  }

  # DEBUGGING ONLY TODO REMOVE IN PROD
  puts "Data passed to stripe: #{stripe_data.to_json}"

  # Make request to Stripe
  stripe_response = HTTP.post(STRIPE_CONNECTED_ACCT_URL,
                              form: stripe_data)

  # Check that we have a returned success
  halt 400, 'Something went wrong' if stripe_response.code != 200

  # Response is valid, store informaton specific to the retailer in firestore
  # {
  #     "token_type": "bearer",
  #     "stripe_publishable_key": "{PUBLISHABLE_KEY}",
  #     "scope": "read_write",
  #     "livemode": false,
  #     "stripe_user_id": "{ACCOUNT_ID}",
  #     "refresh_token": "{REFRESH_TOKEN}",
  #     "access_token": "{ACCESS_TOKEN}"
  #   }

  # TODO: save this stuff in firestore
  puts stripe_response.code
  puts stripe_response.body
  # log_info(stripeResponse)

  # If all this is done and good, return a success message
  log_info('Success!')
  status 201
  # end
end
