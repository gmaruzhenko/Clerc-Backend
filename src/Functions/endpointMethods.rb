module EndpointMethods

  def createCustomer
    customer = Stripe::Customer.create
    log_info("Customer created with ID #{customer[:id]}")
    # Create customer successful - return its id
    status 201
    return customer[:id].to_json
  end

end