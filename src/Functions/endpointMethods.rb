module EndpointMethods

  def createCustomer
    begin
      customer = Stripe::Customer.create
    rescue Stripe::StripeError => e
      status 402
      return "Error creating customer #{e.message}"

    log_info("Customer created with ID #{customer[:id]}")
    # Create customer successful - return its id
    end
    status 201
    return customer.id.to_json
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
    log_info 'Charge successful'
    status 201
    # Return the charge ID
    return charge.id
  end

  def connectStandardAccount (json_input , firestore)

    # Check that it's not empty, otherwise continue
    halt 400, 'Invalid request - no JSON given' if json_input.empty?

    new_account_auth = json_input['account_auth_code']
    new_account_name = json_input['vendor_name']

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
end