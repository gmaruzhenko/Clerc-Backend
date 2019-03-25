#!/usr/bin/env bash

# make sure to have jq installed for pretty json
#feel free to comment out tests for convenience
echo "Test connection "
curl -X GET http://localhost:4567/
echo "Create Ephemeral Key"
curl -d '{"customer_id":"cus_Eic7D12EByBANL","stripe_version":"2019-03-14"}' -H "Content-Type: application/json" -X POST http:/localhost:4567/customers/create-ephemeral-key | jq
echo "Create Customer"
curl -i -X GET http://localhost:4567/customers/create
echo "Charge"
#TODO FIX REQUEST below plz FRANK
curl -d '{"customer_id": "cus_EkoUsnxHpxTvsh", "amount": "10", "source": "src_1EHMXOLrlHDdcgZ3YTXRwjkd", "CONNECTED_STRIPE_ACCOUNT_ID": "acct_1EALLCF8Tv70HUia" }' -H "Content-Type: application/json" -X POST http://localhost:4567/charge | jq
echo "Create standard account"
curl -d '{"account_auth_code":"ac_Ek9CCOHu8rMi3nNMIzY5A6wIlOJlSUvy","vendor_name":"test-store-123"}' -H "Content-Type: application/json" -X POST http://localhost:4567/vendors/connect-standard-account






