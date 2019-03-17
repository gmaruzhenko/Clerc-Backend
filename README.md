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
#### Authenticate