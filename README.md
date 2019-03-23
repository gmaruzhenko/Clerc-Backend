# Ruby Backend for Clerc

### Setup 
1. Install Bundler (Dependency Manager)
```gem install bundler```
2. Install required dependencies with Bundler (in root directory)
```bundle install```

### Endpoints

##### Base URL
http://34.217.14.89:4567
##### Extensions
GET

    /


    /make_customer
POST

    /charge
    Json Params Required = amount , customer_id , CONNECTED_STRIPE_ACCOUNT_ID
    
    /create-standard-account
    Json Params Required = account_auth_code
    
### Operation
0. FOR LOCAL DEVELOPMENT: Place .env file (located in Clerc's Google Drive/Code/Keys/.env) in src
0. Add mvp-1.pem from lastpass to a file in your home directory.
0. Set Google Environment variable (Get JSON from Google Drive - place this in main directory - this won't be committed)
```export GOOGLE_APPLICATION_CREDENTIALS="../[FILE_NAME].json"```
1. Connect to EC2
```ssh -i "mvp-1.pem" ubuntu@ec2-34-217-14-89.us-west-2.compute.amazonaws.com```
2. Run server
```ruby server.rb```
3. You can now run the following:
- Test connection:

```curl -X GET http://34.217.14.89:4567/```

- Make customer:

```curl -i -X GET  http://34.217.14.89:4567/make_customer```
- Charge: 

```curl -d '{"amount":"1000", "customer_id":"cus_Eic7D12EByBANL", "CONNECTED_STRIPE_ACCOUNT_ID":"acct_1EALLCF8Tv70HUia"}' -H "Content-Type: application/json" -X POST http://34.217.14.89:4567/charge```
- Create connected account:

```curl -d '{"account_auth_code":"ac_Eix70se8M3dejLmSxB2PMV3A7lQUjqg0"}' -H "Content-Type: application/json" -X POST http://34.217.14.89:4567/create-standard-account```

- Create ephemeral key:

```curl -d '{"customer_id":"cus_Eic7D12EByBANL","stripe_version":"2019-03-14"}' -H "Content-Type: application/json" -X POST http:/34.217.14.89:4567/gen_ephemeral_key```

### Account notes
- **Primary:** Main Stripe Connect Account
- **Connected - 1:** Connected account to main stripe account

##### ADDITIONAL INFO: Connected - 1 
CONNECTED_STRIPE_ACCOUNT_ID=```acct_1EALLCF8Tv70HUia```
``` 
curl -d '{"amount":"1000", "customer_id":"cus_EiVLxx6AchEMo9", "CONNECTED_STRIPE_ACCOUNT_ID":"acct_1EF7IEK75jC5vRr0"}' -H "Content-Type: application/json" -X POST http://34.217.14.89:4567/charge
```

### Deployment
IMPORTANT: Set environment variable for Google Firestore as defined here: https://cloud.google.com/docs/authentication/getting-started
0. Have mvp.pem in the directory you are running the following command with.
1. Connect to EC2
```ssh -i "mvp-1.pem" ubuntu@ec2-34-217-14-89.us-west-2.compute.amazonaws.co```
2. Run server to unix shell
```nohup ruby Clerc-Backend/src/server.rb &```

### Monitoring
1. Find pid of server is by looking for ruby server (number on immediate right of ubuntu):
```ps aux | grep ruby```
2. Tail to get logs of process with pid (ex <pid> = 8381):
````tail -f /proc/<pid>/fd/1````