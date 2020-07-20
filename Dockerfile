FROM golang:1.14.4-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache bash openssl

COPY ./service /tara-mock/service
COPY ./config/certs /tara-mock/service/vault
COPY ./config/config.json /tara-mock/service/config.json

WORKDIR /tara-mock/service

CMD ["go", "run", ".", "-conf", "./config.json"]