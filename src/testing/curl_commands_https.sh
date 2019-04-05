#!/usr/bin/env bash

#feel free to comment out tests for convenience
echo "Test connection "
curl --cacert localhost.cert -X GET https://localhost:4000/
echo "Create Ephemeral Key"
curl -d '{"customer_id":"cus_Eic7D12EByBANL","stripe_version":"2019-03-14"}' -H "Content-Type: application/json"  --cacert localhost.cert  -X POST https:/localhost:4000/customers/create-ephemeral-keyecho "Create Customer"
curl --cacert localhost.cert -X GET https://localhost:4000/customers/create
echo "Charge"
curl  -d '{"customer_id": "cus_EkoUsnxHpxTvsh", "amount": 1000, "source": "src_1EHMXOLrlHDdcgZ3YTXRwjkd", "CONNECTED_STRIPE_ACCOUNT_ID": "acct_1EALLCF8Tv70HUia" }' -H "Content-Type: application/json" --cacert localhost.cert -X POST https://localhost:4000/charge
echo "
Create standard account"
curl  -d '{"account_auth_code":"ac_Em0BNEqBqTW3KMc5jaJW38HL5E1KjlhC","vendor_name":"test-store-123"}' -H "Content-Type: application/json" --cacert localhost.cert -X POST http://localhost:4000/vendors/connect-standard-account
echo "
"


#In Https
#curl --cacert localhost.cert -X GET https://localhost:4000/





