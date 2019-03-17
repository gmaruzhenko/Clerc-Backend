#
#   Created by Georgiy Maruzhenko on 2019-03-16.
#   Copyright © 2019 Georgiy Maruzhenko. All rights reserved.
#
require 'sinatra'
require 'stripe'
require 'json'

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

get '/make_customer' do
  customer = Stripe::Customer.create()
  status 201  #successful in creating a stripe customer
  return log_info( customer[:id]+"\n")
end


def authenticate!
  # This code simulates "loading the Stripe customer for your current session".
  # Your own logic will likely look very different.
  return @customer if @customer
  if session.has_key?(:customer_id)
    customer_id = session[:customer_id]
    begin
      @customer = Stripe::Customer.retrieve(customer_id)
    rescue Stripe::InvalidRequestError
    end
  else
    begin
      @customer = Stripe::Customer.create(json_params)
    rescue Stripe::InvalidRequestError
    end
    session[:customer_id] = @customer.id
  end
  @customer
end
