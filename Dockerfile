FROM alpine:3.9

RUN apk --update --upgrade add \
        lastpass-cli bash docker jq

COPY ./apply-secret.sh /apply-secret.sh
COPY ./run.sh /run.sh
COPY ./lastpass-login.sh /lastpass-login.sh

COPY ./config /config
