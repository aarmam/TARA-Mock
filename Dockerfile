FROM golang:1.14.4-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache bash openssl

COPY ./service /tara-mock/service
COPY ./genkeys/generated/service /tara-mock/service/vault

WORKDIR /tara-mock/service

CMD ["go", "run", ".", "-conf", "./config.json"]