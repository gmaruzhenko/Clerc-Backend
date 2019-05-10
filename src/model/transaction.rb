# Transaction object that corresponds to Firestore schema
# Only has attributes for what we currently need for receipt emails
class Transaction

  attr_reader :txn_id, :total_amount, :taxes_amount, :date, :store_id, :items

  # Constructor
  def initialize(txn_id, total_amount, taxes_amount,
                 date, store_id, items)
    @txn_id = txn_id
    @total_amount = total_amount
    @taxes_amount = taxes_amount
    @date = date
    @store_id = store_id
    @items = items
  end

  # Nested class for an item object within a transaction
  class Item

    attr_reader :name, :cost, :price_unit, :quantity

    def initialize(name, cost, price_unit, quantity)
      @name = name
      @cost = cost
      @price_unit = price_unit
      @quantity = quantity
    end

  end

end
