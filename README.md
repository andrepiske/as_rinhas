

```
docker run --rm -ti -p 27017:27017 mongo:7.0.5
DB_RESET=1 RUBY_YJIT_ENABLE=1 bundle exec ruby app/server.rb

k6 run -d 10s --vus 4 load-test/basic.js
````
