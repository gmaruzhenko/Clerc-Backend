#
#   Created by Georgiy Maruzhenko on 2019-03-16.
#   Copyright © 2019 Georgiy Maruzhenko. All rights reserved.
#
require 'sinatra'
require 'stripe'
require 'json'
require 'http'
require 'google/cloud/firestore'
require_relative 'Model/Vendor'


# Load environment variables for development (comment out in Prod)
# You can download the required .env file from Google Drive. See README
require 'dotenv'
Dotenv.load

# Loading environment variables will likely look very different in EC2
FIREBASE_PROJ_ID = ENV['FIREBASE_PROJ_ID'].freeze
STRIPE_API_SECRET = ENV['STRIPE_API_SECRET'].freeze
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


# Saves connected account to firestore and returns the firebase ID
def save_vendor(vendor)

  firestore = Google::Cloud::Firestore.new project_id: FIREBASE_PROJ_ID
  puts 'Firestore client initialized'

  # Reference to the vendors collection
  vendors_ref = firestore.col 'vendors'
  basic_vendor_data = {
    name: vendor.name
  }
  puts "Saving vendor: #{vendor.name}"

  added_vendor_ref = vendors_ref.doc
  added_vendor_ref.set basic_vendor_data
  puts "Successfully saved vendor #{vendor.name} with ID: #{added_vendor_ref.document_id}."

  # Now save all the stripe information
  vendor_stripe_ref = added_vendor_ref.col('backend').doc('stripe')
  stripe_data = {
    stripe_publishable_key: vendor.stripe_publishable_key,
    stripe_user_id: vendor.stripe_user_id,
    stripe_refresh_token: vendor.stripe_refresh_token,
    stripe_access_token: vendor.stripe_access_token
  }
  vendor_stripe_ref.set stripe_data
  puts 'Successfully saved vendor Stripe data'

  # Return the firebase ID
  added_vendor_ref.document_id
end

# Retrieves a connected account from firestore
# TODO make this function
# def getVendor; end

helpers do
  # Json parser with error check
  def json_params
    JSON.parse(request.body.read)
  rescue StandardError
    halt 400, { message: 'Invalid JSON' }.to_json
  end

  # send log info to console for debugging
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

  # Get params
  json_input = json_params

  # Check that it's not empty, otherwise continue
  halt 400, 'Invalid request' if json_input.empty?

  new_account_auth = json_input['account_auth_code']

  # Retrieve required fields from Stripe
  # Required data to pass
  stripe_data = {
    client_secret: STRIPE_API_SECRET,
    code: new_account_auth,
    grant_type: 'authorization_code'
  }

  # DEBUGGING ONLY TODO REMOVE IN PROD
  puts "Data passed to stripe: #{stripe_data.to_json}"

  # Make request to Stripe
  stripe_response = HTTP.post(STRIPE_CONNECTED_ACCT_URL,
                              form: stripe_data)

  # DEBUGGING ONLY TODO REMOVE IN PROD
  puts "Stripe response body: #{stripe_response.body}"

  # Check that we have a returned success
  halt 400, 'Something went wrong' if stripe_response.code != 200

  # Response is valid, store information specific to the retailer in firestore
  stripe_response_body = JSON.parse(stripe_response.body) #TODO extract as helper function
  vendor_pub_key = stripe_response_body['stripe_publishable_key']
  vendor_user_id = stripe_response_body['stripe_user_id']
  vendor_refresh_token = stripe_response_body['refresh_token']
  vendor_access_token = stripe_response_body['access_token']
  # Construct the vendor object
  new_vendor = Vendor.new(nil, "Test", vendor_pub_key, vendor_user_id, vendor_refresh_token, vendor_access_token)

  firebase_id = save_vendor new_vendor

  log_info('Success in creating standard account!')

  # Return the firebase ID
  status 201
  firebase_id
end

#generates temp key for ios
# TODO add this to readme below
# curl -d '{"customer_id":"cus_Eic7D12EByBANL","stripe_version":"2019-03-14"}' -H "Content-Type: application/json" -X POST http:/localhost:4567/gen_ephemeral_key
# {"id":"ephkey_1EGTyPLrlHDdcgZ3QoKMX3rd","object":"ephemeral_key","associated_objects":[{"id":"cus_Eic7D12EByBANL","type":"customer"}],"created":1553186553,"expires":1553190153,"livemode":false,"secret":"ek_test_YWNjdF8xRUVpaE9McmxIRGRjZ1ozLEhUMWNPc00zbXNCQjZ0UGNhRjJjVG9nRXVVWFUyWWs_00IN27Z9Ku"}
post '/gen_ephemeral_key' do

  json_input = json_params
  stripe_version = json_input['stripe_version']
  customer_id = json_input['customer_id']

  begin
    key = Stripe::EphemeralKey.create(
        {customer: customer_id},
        {stripe_version: stripe_version}
    )
  rescue Stripe::StripeError => e
    status 402
    return log_info("Error creating ephemeral key: #{e.message}")
  end

  content_type :json
  status 200
  return key.to_json
end
