swift build --destination /Library/Developer/Destinations/amd64-ubuntu-bionic.json
docker build --file Dockerfile-amd64 --tag echoserver:amd64-latest .
