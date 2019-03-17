#
#   Created by Georgiy Maruzhenko on 2019-03-16.
#   Copyright © 2019 Georgiy Maruzhenko. All rights reserved.
#
require 'sinatra'
require 'stripe'
require 'json'

#TODO make stripe api key initilized from request once stripe connect is ready
Stripe.api_key = "sk_test_dUndr7GHsaxgYD9o9jxn6Kmy"

def log_info(message)
  puts "\n" + message + "\n\n"
  return message
end

helpers do
  def json_params
    begin
      JSON.parse(request.body.read)
    rescue
      halt 400, { message:'Invalid JSON' }.to_json
    end
  end
end


get '/' do
  status 200
  return log_info("Connection Successful")
end
#
# Create a customer in our platform account
#
get '/make_customer' do
  customer = Stripe::Customer.create()
  status 201  #successful in creating a stripe customer
  return log_info( customer[:id]+"\n")
end

#
#Creates a charge on a stripe connected account
#

post '/charge' do
  json_recieved = json_params

  #TODO make token request first between customer and store
  token = Stripe::Token.create({
                                   :customer => json_recieved['customer_id'],
                               }, {:stripe_account => json_recieved['store_account_id']})

  charge = Stripe::Charge.create({
                                     amount: json_recieved['amount'],
                                     currency: "cad",
                                     source: token.id,
                                     application_fee_amount: 123,
                                 }, stripe_account: json_recieved['store_account_id'])
  status 201

end
