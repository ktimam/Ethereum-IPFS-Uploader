FROM ubuntu:16.04
MAINTAINER Karim "ktimam@gmail.com"

RUN apt-get update && apt-get install bc && apt-get -y install curl
CMD echo $ARG0 >> $ARG1 | curl -s "https://ipfs.infura.io:5001/api/v0/add?pin=false" -X POST -H "Content-Type: multipart/form-data" -F file=@"./$ARG1"