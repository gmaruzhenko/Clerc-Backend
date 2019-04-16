### JWT documentation
####Algorithm
HS256 (HMAC with SHA-256) symmetric algorithm 
####Encryption & Decryption key
clerc_jwt_fast.key -> 512 bit OPENSSH generated key
#####256 vs 512 vs 1024 vs 2048 bit
512 bit offers good strength but doesnt sacrifice speed since we will need to run decryption on every call to validate users. 
more info at => ```https://medium.com/@siddharthac6/json-web-token-jwt-the-right-way-of-implementing-with-node-js-65b8915d550e```
####Usage
All calls now required additional field "token" that contains a jwt.
To get a new jwt send user ID to /refresh endpoint
####Future TODO
- Add header with authentication instead of sending token in body
- Add Authorization checks for endpoints that will be generated in /refresh

