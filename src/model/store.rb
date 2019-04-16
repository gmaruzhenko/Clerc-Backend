# Store object with all the information needed for Stripe
class Store
  # Define getters (Store is read-only)
  attr_reader :firebase_id, :name, :stripe_publishable_key, :stripe_user_id,
              :stripe_access_token, :stripe_refresh_token, :txn_fee_base,
              :txn_fee_percent, :default_currency
  # We can change firebase id at a later time
  attr_writer :firebase_id

  @firebase_id
  @name
  @stripe_publishable_key
  @stripe_user_id
  @stripe_refresh_token
  @stripe_access_token
  @txn_fee_base
  @txn_fee_percent
  @default_currency

  # Constructor
  def initialize(firebase_id, name, stripe_publishable_key,
                 stripe_user_id, stripe_refresh_token, stripe_access_token,
                 txn_fee_base, txn_fee_percent, default_currency)
    @firebase_id = firebase_id
    @name = name
    @stripe_publishable_key = stripe_publishable_key
    @stripe_user_id = stripe_user_id
    @stripe_refresh_token = stripe_refresh_token
    @stripe_access_token = stripe_access_token
    @txn_fee_base = txn_fee_base
    @txn_fee_percent = txn_fee_percent
    @default_currency = default_currency
  end
end
