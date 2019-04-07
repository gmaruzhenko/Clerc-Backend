#!/usr/bin/env bash

curl  --cacert localhost.cert  -X GET https:/localhost:4000/jwt/generate
curl -d '{"token":"eyJhbGciOiJIUzI1NiJ9.eyJoZWxsbyI6IndvcmxkIiwiZXhwIjoxNTU0Njc3MTEwfQ.HjdXTP4GDVksz8MnS6uFqip4NV-qC9Ca3uQtnR3ZMrU"}'  --cacert localhost.cert  -X POST https:/localhost:4000/jwt/validate