# Ruby Backend for Clerc

### Setup 
1. Install Bundler (Dependency Manager)
```gem install bundler```
2. Install required dependencies with Bundler (in root directory)
```bundle install```

### Endpoints

##### Base URL
http://34.219.126.153:4567
##### Extensions
GET

    /

    /make_customer
POST

    /charge
    Json Params Required = amount , customer_id , CONNECTED_STRIPE_ACCOUNT_ID
    
### Operation
0. Add mvp-1.pem from lastpass to a file in your home directory.
0. Set Google Environment variable (Get JSON from Google Drive - place this in main directory - this won't be committed)
```export GOOGLE_APPLICATION_CREDENTIALS="/home/user/Downloads/[FILE_NAME].json```
1. Connect to EC2
```ssh -i "mvp-1.pem" ubuntu@ec2-34-219-126-153.us-west-2.compute.amazonaws.com```
2. Run server
```ruby server.rb```
3. You can now run the following:
- Test connection:
```curl -X GET http://34.219.126.153:4567/```

    Expected output =
```Connection Successful```
- Make customer:
```curl -i -X GET  http://34.219.126.153:4567/make_customer```
- Charge: 
```curl -d '{"amount":"1000", "customer_id":"cus_Eic7D12EByBANL", "CONNECTED_STRIPE_ACCOUNT_ID":"acct_1EALLCF8Tv70HUia"}' -H "Content-Type: application/json" -X POST http://34.219.126.153:4567/charge```

###Account notes
#####Sample
MAIN ACCOUNT

#####test1
CONNECTED_STRIPE_ACCOUNT_ID =acct_1EALLCF8Tv70HUia
``` 
curl -d '{"amount":"1000", "customer_id":"cus_EiVLxx6AchEMo9", "CONNECTED_STRIPE_ACCOUNT_ID":"acct_1EF7IEK75jC5vRr0"}' -H "Content-Type: application/json" -X POST http://34.219.126.153:4567/charge
```

### Deployment
IMPORTANT: Set environment variable for Google Firestore as defined here: https://cloud.google.com/docs/authentication/getting-started