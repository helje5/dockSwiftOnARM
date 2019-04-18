#!/bin/sh
curl -X "POST" "http://localhost:8080/echo" \
     -H 'Content-Type: text/plain; charset=utf-8' \
     -d $'{
  "sometag": "with some value",
  "someothertag": "and some other value"
}'
