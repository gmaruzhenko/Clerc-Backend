# Ruby Backend for Clerc

### Setup 
1. Install Bundler (Dependency Manager)
```gem install bundler```
2. Install required dependencies with Bundler (in root directory)
```bundle install```

### Operation
1. Start the server
```ruby server.rb```
2. in another window curl
```curl -i -X POST -H "Content-Type: application/json" -d'{"description":"sample", "my_customer_id":"12345"}' http://localhost:4567/authenticate```

### Endpoints
####Base URL
http://34.219.126.153:4567
####Extensions
/

/make_customer

/charge
#### Authenticate

### Testing
0. Add mvp-1.pem from lastpass to a file in your home directory.
 
(need your IP as well to add to firewall whitelist SSH call below)
1. Connect to ec2
```ssh -i "mvp-1.pem" ubuntu@ec2-34-219-126-153.us-west-2.compute.amazonaws.com```
2. run server
```ruby server.rb```
3. In another tab run any of following
- Test connection:
```curl -X GET http://34.219.126.153:4567/```
Expected output
```Connection Successful```
- Make customer:
```curl -i -X GET  http://34.219.126.153:4567//make_customer```
- Charge: 
``` 
curl -d '{"amount":"1000", "customer_id":"cus_EiVLxx6AchEMo9", "CONNECTED_STRIPE_ACCOUNT_ID":"acct_1EF7IEK75jC5vRr0"}' -H "Content-Type: application/json" -X POST http://34.219.126.153:4567/charge
```