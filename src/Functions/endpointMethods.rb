module EndpointMethods

  def createCustomer
    customer = Stripe::Customer.create
    log_info("Customer created with ID #{customer[:id]}")
    # Create customer successful - return its id
    status 201
    return customer[:id].to_json
  end

  def createEphemeralKey (json_input)

    stripe_version = json_input['stripe_version']
    customer_id = json_input['customer_id']

    begin
      key = Stripe::EphemeralKey.create(
          { customer: customer_id },
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

end