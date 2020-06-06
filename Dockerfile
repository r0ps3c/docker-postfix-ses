FROM alpine

RUN apk add --update postfix ca-certificates bash cyrus-sasl-plain cyrus-sasl-login && \
	rm -rfv /var/cache/apk/*
COPY scripts /opt/postfix/scripts
EXPOSE 25
ENTRYPOINT ["/opt/postfix/scripts/start.sh"]
