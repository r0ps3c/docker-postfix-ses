FROM alpine

RUN apk add --update postfix ca-certificates bash libsasl cyrus-sasl-login && \
	rm -rfv /var/cache/apk/*
COPY scripts /opt/postfix/scripts
EXPOSE 25
ENTRYPOINT ["/opt/postfix/scripts/start.sh"]
