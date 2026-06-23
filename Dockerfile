FROM alpine:3.21

RUN apk add --update postfix ca-certificates libsasl cyrus-sasl-login openssl && \
	rm -rf /var/cache/apk/*

COPY scripts /opt/postfix/scripts

EXPOSE 25

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
	CMD postfix status || exit 1

ENTRYPOINT ["/opt/postfix/scripts/start.sh"]
