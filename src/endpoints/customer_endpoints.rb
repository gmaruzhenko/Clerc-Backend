require_relative '../service/firestore_service'
require_relative 'endpoint_helper'
require_relative '../util'

module CustomerEndpoints
  include EndpointHelper
  include Util

  #
  # Creates an empty new Stripe customer
  # @return customer ID if successful
  #
  def create_customer
    begin
      customer = Stripe::Customer.create
      # Create customer successful - return its id
      log_info("Customer created with ID #{customer[:id]}")
    rescue Stripe::StripeError => e
      return_error 402, "Error creating customer #{e.message}"
    end
    status 201
    { customer_id: customer.id }.to_json
  end

  #
  # Creates a short-lived authentication key
  # for the stripe customer and returns it if successful
  #
  def create_ephemeral_key(json_input)
    stripe_version = json_input['stripe_version']
    customer_id = json_input['customer_id']

    begin
      key = Stripe::EphemeralKey.create(
        { customer: customer_id },
        stripe_version: stripe_version
      )
    rescue Stripe::StripeError => e
      log_info "Error calling stripe to get ephemeral key: #{e.message}"
      return_error 402, "Error creating ephemeral key: #{e.message}"
    end

    status 200
    # Just call key.to_json -> no need to wrap in an object
    # This gets processed by the mobile Stripe SDK directly
    key.to_json
  end

  #
  # Charges a customer with a given store
  # Returns the transaction ID if successful
  #
  def charge(json_input, firestore_service)
    # Check that input is not empty, otherwise continue
    halt 400, 'Invalid request - no JSON given' if json_input.empty?

    # Check that required params are passed
    cust_id = json_input['customer_id']
    firebase_store_id = json_input['firebase_store_id']
    amount = json_input['amount']
    payment_src = json_input['source']
    charge_description = json_input['description']
    statement_descriptor = json_input['statement_descriptor']

    # Note : we don't need payment source because Stripe's mobile SDK
    # automatically updates payment method via standard integration
    if cust_id.nil? || firebase_store_id.nil? || amount.nil? || payment_src.nil?
      return_error 400, 'Invalid request - required params not passed'
    end

    # Try getting the Store object from firebase
    store_from_firebase = firestore_service.load_store firebase_store_id
    return_error 400, "Store #{firebase_store_id}  not found" if store_from_firebase.nil?

    store_stripe_id = store_from_firebase.stripe_user_id

    # Calculate the fee to charge
    application_fee = amount * store_from_firebase.txn_fee_percent / 100
    application_fee += store_from_firebase.txn_fee_base
    puts application_fee # TODO: REMOVE ME AFTER TESTING

    begin
      # This creates a shared customer token, required for connected accounts
      token = Stripe::Source.create({
                                      customer: cust_id,
                                      original_source: payment_src,
                                      usage: 'reusable'
                                    }, stripe_account: store_stripe_id)
      # This creates a charge token - the customer MUST have a payment method
      # Payment method should be pre-populated with Stripe's mobile SDKs
      charge = Stripe::Charge.create({
                                       amount: amount,
                                       currency: 'cad',
                                       source: token.id,
                                       application_fee_amount: application_fee,
                                       description: charge_description,
                                       statement_descriptor: statement_descriptor
                                     }, stripe_account: store_stripe_id)
    rescue Stripe::StripeError => e
      return_error 402, "Error creating charge: #{e.message}"
    end

    # Charge successful
    log_info 'Charge successful'
    status 201
    # Return the charge ID
    { charge_id: charge.id }.to_json
  end
end
