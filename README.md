# Clerc-Backend

###Runing
1. install ruby 
2. run 
    ```ruby server.rb```
3. in another window curl
```curl -i -X POST -H "Content-Type: application/json" -d'{"description":"sample", "my_customer_id":"12345"}' http://localhost:4567/authenticate```