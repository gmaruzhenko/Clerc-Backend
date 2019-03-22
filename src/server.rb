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

firestore = Google::Cloud::Firestore.new project_id: FIREBASE_PROJ_ID
puts 'Firestore client initialized'

helpers do
  # JSON Parameter parser for incoming response body
  def json_params
    JSON.parse(request.body.read)
  rescue StandardError
    halt 400, { message: 'Invalid JSON' }.to_json
  end

  # Logging
  def log_info(message)
    puts "\nINFO: " + message + "\n\n"
    message
  end
end

# Test endpoint to check if server is up
get '/' do
  status 200
  return log_info("Connection Successful\n")
end

# Create a customer in our platform account
get '/customers/create' do
  customer = Stripe::Customer.create
  log_info(customer[:id] + "\n")
  # Create customer successful - return its id
  status 201
  customer[:id]
end

# generates temp key for ios
post '/customers/create-ephemeral-key' do

  json_input = json_params
  stripe_version = json_input['stripe_version']
  customer_id = json_input['customer_id']

  begin
    key = Stripe::EphemeralKey.create(
      {customer: customer_id},
      stripe_version: stripe_version
    )
  rescue Stripe::StripeError => e
    status 402
    return log_info("Error creating ephemeral key: #{e.message}")
  end

  content_type :json
  status 200
  return key.to_json
end

# Creates a charge on a stripe connected account
post '/charge' do

  # Get params
  json_received = json_params

  # Check that input is not empty, otherwise continue
  halt 400, 'Invalid request - no JSON given' if json_received.empty?
  # Check that required params are passed
  cust_id = json_received['customer_id']
  connected_vendor_id = json_received['CONNECTED_STRIPE_ACCOUNT_ID']
  # TODO - payment source is not used because we need to use a shared customer token
  # TODO - we need to see if the iOS integration automatically updates payment for the customer (i.e. does selected payment change?)
  # TODO - we will ignore this parameter for now
  # payment_source = json_received['payment_source']
  amount = json_received['amount']

  if cust_id.nil? || connected_vendor_id.nil? || amount.nil? # || payment_source.nil?
    halt 400, 'Invalid request - required params not passed'
  end

  begin
    # This creates a shared customer token, required for connected accounts
    token = Stripe::Token.create({
                                   customer: cust_id
                                 }, stripe_account: connected_vendor_id)
    # This creates a charge the token - the customer MUST have a payment method
    charge = Stripe::Charge.create({
                                     amount: amount,
                                     currency: 'cad',
                                     source: token.id,
                                     # TODO: fill the below in from additional params
                                     application_fee_amount: 5,
                                     description: 'description',
                                     statement_descriptor: 'Custom descriptor'
                                   }, stripe_account: connected_vendor_id)
  rescue Stripe::StripeError => e
    status 402
    return log_info("Error creating charge: #{e.message}")
  end

  # Charge successful
  if charge[:status] == 'succeeded'
    log_info 'Charge successful'
    status 201
    # Return the charge ID
    charge.id

  # Charge unsuccessful
  else
    log_info 'Charge unsuccessful'
    log_info charge.to_json #TODO this is for debugging only
    # TODO: Do what when charge unsuccessful??? - test declined card
  end
end

# This is called by front-end once the connected account is authorized
# Once the business gives us authorization, frontend will receive a code
# which is then passed to this method through a backend call.
# We will use the AUTHORIZATION_CODE to retrieve credentials for the business
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
