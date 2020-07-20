FROM golang:1.14.4-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache bash openssl

COPY ./genkeys /genkeys
WORKDIR /genkeys
RUN chmod +x ./genkeys.sh
RUN ./genkeys.sh

COPY ./service /tara-mock/service
WORKDIR /tara-mock/service/vault
RUN cp /genkeys/generated/service/* .

WORKDIR /tara-mock/service
CMD ["go", "run", ".", "-conf", "./config.json"]