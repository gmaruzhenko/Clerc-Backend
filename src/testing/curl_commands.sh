#!/usr/bin/env bash
#USAGE
#run bash curl_commands.ah to hit all endpoints
JWT="eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhaFZzcHRkZ1BZaFlQZ3FtQmQyejVrcmhvOHMxIiwiZXhwIjoxNTU2NDk2NzEyfQ.ewGL8OVmgcKy7rBbo2ViGqvKUerIIeo5sMLUwxbNBXQ"
printf "Test connection\n"
curl -X GET http://localhost:4567/

printf "\n\nValidate JWT Refresh\n"
curl -d '{"user_id":"ahVsptdgPYhYPgqmBd2z5krho8s1"}' -H "Content-Type: application/json" -X POST http:/localhost:4567/jwt/refresh
printf $JWT
printf "\n\nCreate Ephemeral Key\n"
curl -d '{"customer_id":"cus_Eic7D12EByBANL","stripe_version":"2019-03-14","token":"$JWT"}' -H "Content-Type: application/json" -X POST http:/localhost:4567/customers/create-ephemeral-key

printf "\n\nCreate Customer\n"
curl -d '' -X POST http://localhost:4567/customers/create

printf "\n\nCharge\n"
curl -d '{"customer_id": "cus_Eki4HaYdTlXbfc", "amount": 1000, "source": "src_1EHHPTLrlHDdcgZ3P8HWzrrI", "firebase_store_id": "kUCDZnMH33UFOoXfmJjm","token":"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzR3BNYUVtMURTaE5KekRGeFRLODUzS3NDWUkzIiwiZXhwIjoxNTU1ODM5MjgyfQ.UuvmV23v1u35IT03rOcvltZxwzQ1JBB87uT2YVS39iY" }' -H "Content-Type: application/json" -X POST http://localhost:4567/charge

printf "\n\nCreate standard account\n"
printf "Currently not testable"
#curl -d '{"account_auth_code":"ac_Em0BNEqBqTW3KMc5jaJW38HL5E1KjlhC","vendor_name":"test-store-123","token":"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzR3BNYUVtMURTaE5KekRGeFRLODUzS3NDWUkzIiwiZXhwIjoxNTU1ODM5MjgyfQ.UuvmV23v1u35IT03rOcvltZxwzQ1JBB87uT2YVS39iY"}' -H "Content-Type: application/json" -X POST http://localhost:4567/vendors/connect-standard-account

printf "\n\n"






