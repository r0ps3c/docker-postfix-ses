#!/bin/sh
set -e

TLS_DIR=/etc/postfix/tls

# Generate a self-signed cert for inbound STARTTLS if no cert is mounted
if [ "${POSTFIX_CHECK}" != "1" ] && [ ! -f "${TLS_DIR}/tls.crt" ]; then
	mkdir -p "${TLS_DIR}"
	openssl req -new -x509 -days 3650 -nodes \
		-out "${TLS_DIR}/tls.crt" \
		-keyout "${TLS_DIR}/tls.key" \
		-subj "/CN=${MY_DOMAIN:-postfix}" \
		2>/dev/null
fi

/opt/postfix/scripts/update-config.sh

if [ "${POSTFIX_CHECK}" = "1" ]; then
	postfix check && echo "ok" || echo "failed"
else
	exec /usr/sbin/postfix start-fg
fi
