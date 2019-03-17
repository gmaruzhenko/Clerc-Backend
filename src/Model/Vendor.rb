# Vendor object with all the information needed for Stripe
class Vendor
    
    # Define getters (Vendor is read-only)
    attr_reader :firebase_id, :name, :stripe_publishable_key, :stripe_user_id, :stripe_access_token, :stripe_refresh_token

    @firebase_id
    @name
    @stripe_publishable_key
    @stripe_user_id
    @stripe_refresh_token
    @stripe_access_token

    # Constructor
    def initialize(firebase_id, name, stripe_publishable_key, stripe_user_id, stripe_refresh_token, stripe_access_token)
        @firebase_id = firebase_id
        @name = name
        @stripe_publishable_key = stripe_publishable_key
        @stripe_user_id = stripe_user_id
        @stripe_refresh_token = stripe_refresh_token
        @stripe_access_token = stripe_access_token
    end
end  

