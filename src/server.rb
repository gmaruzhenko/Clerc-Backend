#
#   Created by Georgiy Maruzhenko on 2019-03-16.
#   Copyright © 2019 Georgiy Maruzhenko. All rights reserved.
#
require 'sinatra'
require 'stripe'
require 'json'

# Our secret api key for logging customers in our account
Stripe.api_key = "sk_test_dUndr7GHsaxgYD9o9jxn6Kmy"


helpers do
  # Json parser with error check
  def json_params
    begin
      JSON.parse(request.body.read)
    rescue
      halt 400, { message:'Invalid JSON' }.to_json
    end
  end
  # send log info to console for debugging
  def log_info(message)
    puts "\n" + message + "\n\n"
    return message
  end
end

# Test endpoint to check if server is up
get '/' do
  status 200
  return log_info("Connection Successful\n")
end

# Create a customer in our platform account
get '/make_customer' do
  customer = Stripe::Customer.create()
  status 201  #successful in creating a stripe customer
  return log_info( customer[:id]+"\n")
end

#Creates a charge on a stripe connected account
post '/charge' do
  json_received = json_params

  token = Stripe::Token.create({
                                   :customer => json_received['customer_id'],
                               }, {:stripe_account => json_received['CONNECTED_STRIPE_ACCOUNT_ID']})

  charge = Stripe::Charge.create({
                                     amount: json_received['amount'],
                                     currency: "cad",
                                     source: token.id,
                                     application_fee_amount: 123,
                                 }, stripe_account: json_received['CONNECTED_STRIPE_ACCOUNT_ID'])
  status 201
end
