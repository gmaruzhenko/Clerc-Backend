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

  def charge (json_input)

    # Check that input is not empty, otherwise continue
    halt 400, 'Invalid request - no JSON given' if json_input.empty?

    # Check that required params are passed
    cust_id = json_input['customer_id']
    connected_vendor_id = json_input['CONNECTED_STRIPE_ACCOUNT_ID']
    amount = json_input['amount']
    payment_src = json_input['source']

    # Note : we don't need payment source because Stripe's mobile SDK
    # automatically updates payment method via standard integration
    if cust_id.nil? || connected_vendor_id.nil? || amount.nil? || payment_src.nil?
      halt 400, 'Invalid request - required params not passed'
    end

    begin
      # This creates a shared customer token, required for connected accounts
      token = Stripe::Source.create({
                                        customer: cust_id,
                                        original_source: payment_src,
                                        usage: 'reusable'
                                    }, stripe_account: connected_vendor_id)
      # This creates a charge token - the customer MUST have a payment method
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
      return charge.id

      # Charge unsuccessful
    else
      log_info 'Charge unsuccessful'
      log_info charge.to_json #TODO: this is for debugging only
      # TODO: Do what when charge unsuccessful??? - test declined card
    end
  end
end