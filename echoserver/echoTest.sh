## Request
curl -X "POST" "http://localhost:8080/echo" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "message": "this message"
}'
