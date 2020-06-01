FROM alpine

RUN apk add --update postfix ca-certificates && \
	rm -rfv /var/cache/apk/*
COPY main.cf.template /etc/postfix
COPY scripts /opt/postfix/scripts
EXPOSE 25
ENTRYPOINT ["/opt/postfix/scripts/start.sh"]
