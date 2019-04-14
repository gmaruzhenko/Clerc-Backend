#!/usr/bin/env bash
# curl commands - use the output from the first to make the second call
curl  --cacert localhost.cert  -X GET https:/localhost:4000/jwt/generate
curl -d '{"token":"eyJhbGciOiJIUzI1NiJ9.eyJoZWxsbyI6IndvcmxkIiwiZXhwIjoxNTU0Njc3MTEwfQ.HjdXTP4GDVksz8MnS6uFqip4NV-qC9Ca3uQtnR3ZMrU"}'  --cacert localhost.cert  -X POST https:/localhost:4000/jwt/validate

# forever token
# eyJhbGciOiJIUzI1NiJ9.eyJjdXN0b21lcl9pZCI6ImN1c19FaWM3RDEyRUJ5QkFOTCIsInN0cmlwZV92ZXJzaW9uIjoiMjAxOS0wMy0xNCIsImV4cCI6MTU1NTIwMjI5Mn0.6diYOXd5mLfoWZyOwpEXH8wCNCsmXAWhi5rBHiSkan0

curl -d '{"token":"eyJhbGciOiJIUzI1NiJ9.eyJjdXN0b21lcl9pZCI6ImN1c19FaWM3RDEyRUJ5QkFOTCIsInN0cmlwZV92ZXJzaW9uIjoiMjAxOS0wMy0xNCIsImV4cCI6MTU1NjIwMzgyMX0.hpaA7QTJlNtfF0dc9KcXtIJt1XTntiv89PDImhFZ51M"}' -H "Content-Type: application/json"  --cacert localhost.cert  -X POST https:/localhost:4000/customers/create-ephemeral-key


