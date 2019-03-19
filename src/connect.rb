
# Import dependencies
require 'sinatra'
require 'stripe'
require 'json'
require 'unirest'
require "google/cloud/firestore"

FIREBASE_PROJ_ID = "paywithclerc" #TODO this should be an environment variable
STRIPE_API_SECRET = "sk_test_BGUip2DhwDI2yHRBHQPTQK7Q" # TODO this should also be an environment variable
STRIPE_CONNECTED_ACCT_URL = "https://connect.stripe.com/oauth/token"
Stripe.api_key = STRIPE_API_SECRET 

# Creates a firestore client
def initFirestoreClient project_id:
    firestore = Google::Cloud::Firestore.new project_id: project_id
    puts "Firestore client initialized"
end

# Saves connected account to firestore and returns the firebase ID
def saveVendor(vendor)

    # Reference to the vendors collection
    vendors_ref = firestore.col "vendors"
    basic_vendor_data = {
        name: vendor.name
    }
    puts "Saving vendor: #{vendor.name}"

    added_vendor_ref = cities_ref.doc
    added_vendor_ref.set data
    puts "Successfully saved vendor #{vendor.name} with ID: #{added_vendor_ref.document_id}."

    # Now save all the stripe information
    vendor_stripe_ref = added_vendor_ref.col("backend").doc("stripe")
    stripe_data = {
        stripe_publishable_key: vendor.stripe_publishable_key,
        stripe_user_id: vendor.stripe_user_id,
        stripe_refresh_token: vendor.stripe_refresh_token,
        stripe_access_token: vendor.stripe_access_token
    }
    vendor_stripe_ref.set stripe_data
    puts "Successfully saved vendor Stripe data"

    # Return the firebase ID
    added_vendor_ref.document_id
end 

# Retrieves a connected account from firestore
def getVendor() 

end

# This is called by front-end once the connected account is authorized
# Once the business gives us authorization, frontend will receive an AUTHORIZATION_CODE
# which is then passed to this method. We will use the AUTHORIZATION_CODE to retrieve credentials for the business
post 'connect/create-standard-account' do

    # This method will use an AUTHORIZATION_CODE (given by stripe) to retrieve a vendor's stripe details
    # Then save those details into firebase as a NEW VENDOR OBJECT, returning the ID of that vendor
    
    # Get the authorization code & cast to string
    name = request["name"].to_str
    authCode = request["account_auth_code"].to_str

    # Check that it's not empty, otherwise continue
    if authCode.empty? || name.empty?
        halt 400, "Invalid request"
    end

    # Retrieve required fields from Stripe
#    curl https://connect.stripe.com/oauth/token \
#   -d client_secret=sk_test_BGUip2DhwDI2yHRBHQPTQK7Q \
#   -d code="{AUTHORIZATION_CODE}" \
#   -d grant_type=authorization_code
    stripeData = {
        :client_secret => STRIPE_API_SECRET,
        :code => authCode,
        :grant_type=> 'authorization_code'
    }
    stripeResponse = Unirest.post STRIPE_CONNECTED_ACCT_URL, parameters: stripeData
    # for debugging
    puts stripeData
    # Check that we have a returned success 
    if (stripeResponse.code != 200)
        halt 400, "Something went wrong"
    end

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

    # TODO save this stuff in firestore
    puts stripeResponse.raw_body
    puts stripeResponse.code
    puts stripeResponse.body

    # If all this is done and good, return the FIREBASE id 
    "Success!"
  end