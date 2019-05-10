require 'google/cloud/firestore'


ID_WITH_TAXES = "ch_1EWmE7D23g1Gx3UfAFB5oH8L"
ID_NO_TAXES = "ch_1EXDd3D23g1Gx3UfLuRRlRd1"
ID_WITH_PRICE_UNIT = ""

# Initialize the base firestore service
firestore = Google::Cloud::Firestore.new project_id: 'paywithclerc-dev'
puts 'Firestore client initialized'

# Initialize our own abstraction service for firestore
firestore_service = FirestoreService.new firestore

firestore_service.get_txn ID_WITH_TAXES