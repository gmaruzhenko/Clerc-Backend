require 'google/cloud/firestore'
require_relative '../service/firestore_service'
require_relative '../service/email_service'

ID_WITH_TAXES = "ch_1EWmE7D23g1Gx3UfAFB5oH8L"
ID_NO_TAXES = "ch_1EXDd3D23g1Gx3UfLuRRlRd1"
ID_WITH_PRICE_UNIT = ""

# Initialize the base firestore service
firestore = Google::Cloud::Firestore.new project_id: 'paywithclerc-dev'
puts 'Firestore client initialized'

# Initialize our own abstraction service for firestore
firestore_service = FirestoreService.new firestore

txn = firestore_service.get_txn ID_WITH_TAXES
# puts txn.store_id
# puts txn.txn_id
# puts txn.date.year
# puts txn.items[0].name
# puts txn.items[0].price_unit.nil?
# puts txn.taxes_amount
# puts txn.total_amount
email_service = EmailService.new firestore_service
email_service.build_email_body txn, 'Frank Jia'