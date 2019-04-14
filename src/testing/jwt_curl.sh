#!/usr/bin/env bash
# curl commands - use the output from the first to make the second call
curl  --cacert localhost.cert  -X POST https:/localhost:4000/jwt/generate
curl -d '{"token":"eyJhbGciOiJIUzI1NiJ9.eyJoZWxsbyI6IndvcmxkIiwiZXhwIjoxNTU0Njc3MTEwfQ.HjdXTP4GDVksz8MnS6uFqip4NV-qC9Ca3uQtnR3ZMrU"}'  --cacert localhost.cert  -X POST https:/localhost:4000/jwt/validate

# forever token
# eyJhbGciOiJIUzI1NiJ9.eyJjdXN0b21lcl9pZCI6ImN1c19FaWM3RDEyRUJ5QkFOTCIsInN0cmlwZV92ZXJzaW9uIjoiMjAxOS0wMy0xNCIsImV4cCI6MTU1NTIwMjI5Mn0.6diYOXd5mLfoWZyOwpEXH8wCNCsmXAWhi5rBHiSkan0

curl -d '{"token":"eyJhbGciOiJIUzI1NiJ9.eyJjdXN0b21lcl9pZCI6ImN1c19FaWM3RDEyRUJ5QkFOTCIsInN0cmlwZV92ZXJzaW9uIjoiMjAxOS0wMy0xNCIsImV4cCI6MTU1NjIwMzgyMX0.hpaA7QTJlNtfF0dc9KcXtIJt1XTntiv89PDImhFZ51M"}' -H "Content-Type: application/json"  --cacert localhost.cert  -X POST https:/localhost:4000/customers/create-ephemeral-key


curl  --cacert localhost.cert -d '{ "customer_id": "cus_Eki4HaYdTlXbfc", "firebase_store_id": "fHwSHMW0kuBbNl6KQ4hG", "amount": 1000, "source": "src_1EHHPTLrlHDdcgZ3P8HWzrrI"}'  -X POST https:/localhost:4000/jwt/generate

# charge token

curl  -d '{ "token": "eyJhbGciOiJIUzI1NiJ9.eyJjdXN0b21lcl9pZCI6ImN1c19Fa2k0SGFZZFRsWGJmYyIsImZpcmViYXNlX3N0b3JlX2lkIjoiZkh3U0hNVzBrdUJiTmw2S1E0aEciLCJhbW91bnQiOjEwMDAsInNvdXJjZSI6InNyY18xRUhIUFRMcmxIRGRjZ1ozUDhIV3pyckkiLCJleHAiOjE1NTUyMDk3Njh9.Dt0T34kuJYOVt-f4m3gjkKbgAmIhoRYpGHMej-k17jM"}' -H "Content-Type: application/json" --cacert localhost.cert -X POST https://localhost:4000/charge


eyJhbGciOiJIUzI1NiJ9.eyJjdXN0b21lcl9pZCI6ImN1c19Fa2k0SGFZZFRsWGJmYyIsImZpcmViYXNlX3ZlbmRvcl9pZCI6InBheXdpdGhjbGVyY18wIiwiYW1vdW50IjoxMDAwLCJzb3VyY2UiOiJzcmNfMUVISFBUTHJsSERkY2daM1A4SFd6cnJJIiwiZXhwIjoxNTU1MjA5NDYyfQ.ZfT8mdGSnB0kiqTTmqntGOFZl_kCLpGqvd5Y-Dz4GZU