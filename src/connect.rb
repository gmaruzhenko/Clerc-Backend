
# Import dependencies
require 'sinatra'
require 'stripe'
require 'json'
require "google/cloud/firestore"

FIREBASE_PROJ_ID = "paywithclerc" #TODO this should be an environment variable
Stripe.api_key = "sk_test_BGUip2DhwDI2yHRBHQPTQK7Q" # TODO this should also be an environment variable

# Creates a firestore client
def initFirestoreClient project_id:
    firestore = Google::Cloud::Firestore.new project_id: project_id
    puts "Firestore client initialized"
end

# Saves connected account to firestore
def saveVendor()

end 

# Retrieves a connected account from firestore
def getVendor() 

end

# This is called by front-end once the connected account is authorized
# Once the business gives us authorization, frontend will receive an AUTHORIZATION_CODE
# which is then passed to this method. We will use the AUTHORIZATION_CODE to retrieve credentials for the business
post 'connect/create-standard-account' do
    log_info(json_params.to_s) # Used for debugging only - remove in production

    # Check that we received a valid authorization code

    # If we received an authorization code, make the Stripe request
#     Post to the following using HTTParty
#     curl https://connect.stripe.com/oauth/token \
#   -d client_secret=sk_test_BGUip2DhwDI2yHRBHQPTQK7Q \
#   -d code="{AUTHORIZATION_CODE}" \
#   -d grant_type=authorization_code

    # Check that we have a non-errored response


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

    # If all this is done and good, return a success message


  end