#!/bin/sh
set -e

for var in RELAYHOST RELAY_NETWORKS MY_DOMAIN SMTP_USER SMTP_PASSWD ROOT_MAIL; do
	eval "val=\$$var"
	if [ -z "$val" ]; then
		echo "ERROR: Required environment variable $var is not set" >&2
		exit 1
	fi
done

config_dir=$(postconf -h config_directory)

postconf -e \
	"relayhost=${RELAYHOST}" \
	"mynetworks=127.0.0.0/8 ${RELAY_NETWORKS}" \
	"mydomain=${MY_DOMAIN}" \
	"smtp_sasl_auth_enable=yes" \
	"smtp_sasl_security_options=noanonymous" \
	"smtp_sasl_password_maps=lmdb:${config_dir}/sasl_passwd" \
	"smtp_use_tls=yes" \
	"smtp_tls_security_level=encrypt" \
	"smtp_tls_note_starttls_offer=yes" \
	"smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt"

TLS_DIR=/etc/postfix/tls
if [ -f "${TLS_DIR}/tls.crt" ] && [ -f "${TLS_DIR}/tls.key" ]; then
	postconf -e \
		"smtpd_tls_cert_file=${TLS_DIR}/tls.crt" \
		"smtpd_tls_key_file=${TLS_DIR}/tls.key" \
		"smtpd_tls_security_level=may" \
		"smtpd_tls_loglevel=1"
fi

printf "%s %s:%s\n" "${RELAYHOST}" "${SMTP_USER}" "${SMTP_PASSWD}" > "${config_dir}/sasl_passwd"
postmap lmdb:"${config_dir}/sasl_passwd"
chmod 600 "${config_dir}/sasl_passwd" "${config_dir}/sasl_passwd.lmdb"

printf "root: %s\n" "${ROOT_MAIL}" > "${config_dir}/aliases"
newaliases
