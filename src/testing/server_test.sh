#!/usr/bin/env bash

#feel free to comment out tests for convenience
echo "Test connection "
curl -k -X GET https://34.217.14.89:4000/
echo "Create Ephemeral Key"
curl -d '{"customer_id":"cus_Eic7D12EByBANL","stripe_version":"2019-03-14"}' -H "Content-Type: application/json"  -k  -X POST https:/34.217.14.89:4000/customers/create-ephemeral-key
echo "Create Customer"
curl -k -X GET https://34.217.14.89:4000/customers/create
echo "Charge"
curl  -d '{ "customer_id": "cus_Eki4HaYdTlXbfc", "firebase_store_id": "fHwSHMW0kuBbNl6KQ4hG", "amount": 1000, "source": "src_1EHHPTLrlHDdcgZ3P8HWzrrI" }' -H "Content-Type: application/json" -k -X POST https://34.217.14.89:4000/charge
echo "
Create standard account - Not working"
#curl  -d '{"account_auth_code":"ac_Em0BNEqBqTW3KMc5jaJW38HL5E1KjlhC","vendor_name":"paywithclerc_0"}' -H "Content-Type: application/json" -k -X POST https://34.217.14.89:4000/vendors/connect-standard-account
echo "

"





