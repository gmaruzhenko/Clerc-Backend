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
  return log_info("Great, your backend is set up. Now you can configure the Stripe example apps to point here.")
end

post '/authenticate' do
  log_info(json_params.to_s)

  #authenticate!
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
