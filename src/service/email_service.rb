require_relative './email_template'
require 'mailgun-ruby'

# Module for sending emails
class EmailService
  # Constructor
  def initialize(firestore_service, api_key)
    @firestore_service = firestore_service
    @mailgun = Mailgun::Client.new api_key
  end

  # TODO currently returns true/false - think this thru?
  # Sends an email receipt for the transaction
  def send_email(txn_id, cust_name, cust_email)
    transaction = @firestore_service.get_txn txn_id

    unless transaction.nil?
      msg_builder = Mailgun::MessageBuilder.new
      msg_builder.from('no-reply@paywithclerc.com', first: 'Clerc')
      msg_builder.add_recipient(:to, cust_email, 'first' => cust_name)
      msg_builder.subject('Your Receipt from Clerc Mobile Checkout')
      msg_builder.body_html(build_email_body(transaction, cust_name))

      result = @mailgun.send_message('paywithclerc.com', msg_builder)

      puts result.body.to_s
      true
    end

    false
  end

  # Builds an HTML email body with the transaction object
  #
  # @param transaction Transaction object
  # @param customer_name Name of the customer, can be nil
  def build_email_body(transaction, customer_name)
    # Duplicate HTML since the EmailTemplate is a constant
    html_body = EmailTemplate::HTML_MAIN.dup
    item_html_template = EmailTemplate::HTML_ITEM_ROW.dup

    # First get store information
    store = @firestore_service.get_store(transaction.store_id)

    # Store Name
    store_name = if !store.nil?
                   store.name
                 else
                   'Store' # Default
                 end
    # TODO: custom receipt messages, etc.

    # Customer Name
    cust_name = if !customer_name.nil?
                  customer_name
                else
                  '' # Default to empty string
                end

    # Transaction Date
    txn_date = if !transaction.date.nil?
                 date = transaction.date
                 date.strftime('%B %d, %Y')
               else
                 '' # Default to empty string
               end

    # Total Amount
    total_amt = if !transaction.total_amount.nil?
                  get_currency_string transaction.total_amount
                else
                  get_currency_string 0 # Default to 0 dollars
                end

    # Tax Amount
    tax_amount = if !transaction.taxes_amount.nil?
                   get_currency_string transaction.taxes_amount
                 else
                   get_currency_string 0
                 end

    # Individual items
    items_html = ''
    items = transaction.items
    if !items.nil? && !items.empty?
      items.each do |item|
        item_html = item_html_template.dup
        # Format: Item Name ($unit_cost per price_unit x quantity)
        # price_unit is null sometimes, ruby will just substitute an empty str
        item_desc = "#{item.name} ($#{item.cost} per #{item.price_unit} x #{item.quantity})"
        item_html.sub! '{ITEM_DESCRIPTION}', item_desc
        item_html.sub! '{ITEM_AMT}', get_currency_string(item.cost * item.quantity)
        items_html += item_html
      end
    end

    # Make all the substitutions
    html_body.sub! '{STORE_NAME}', store_name
    html_body.sub! '{CUSTOMER_NAME}', cust_name
    html_body.sub! '{TRANSACTION_DATE}', txn_date
    html_body.sub! '{TAX_AMT}', tax_amount
    html_body.sub! '{TOTAL_AMT}', total_amt
    html_body.sub! '{ITEMS}', items_html

    html_body
  end

  private

  # Gets a formatted currency string
  def get_currency_string(amount)
    format('$ %0.2f', amount)
  end
end
