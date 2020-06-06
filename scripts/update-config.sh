#!/bin/bash
set -e

function usage() {
	echo "$0 -r <RELAYHOST> -n <RELAYNETWORKS> -d <MYDOMAIN> -s <SRCIP> -u <SMTPUSER> -p <SMTPPASSWD> -r <ROOTMAIL>"
}

while getopts "r:n:d:s:u:p:m:" opt; do
        case $opt in
        r)
                RELAYHOST="${OPTARG}"
                ;;
        n)
                RELAYNETWORKS="${OPTARG}"
                ;;
        d)
                MYDOMAIN="${OPTARG}"
                ;;
        s)
                SRCIP="${OPTARG}"
                ;;
        u)
                SMTPUSER="${OPTARG}"
                ;;
        p)
                SMTPPASSWD="${OPTARG}"
                ;;
        m)
                ROOTMAIL="${OPTARG}"
                ;;

	\?)
                echo "Invalid option $OPTARG" >&2
		usage
                exit 1
                ;;
        :)
                echo "Option $OPTARG requires an argument." >&2
		usage
                exit 1
                ;;
        esac
done


for i in RELAYHOST RELAYNETWORKS MYDOMAIN SRCIP SMTPUSER SMTPPASSWD ROOTMAIL;
do
	if [ -z "${!i}" ]
	then
		echo "missing $i"
		usage
		exit 1
	fi
done

echo "Updating config via postconf"
config_directory=`postconf -h config_directory`
cafile=`apk --quiet info -L ca-certificates-bundle|grep ca-certificates.crt`

postconf -e "relayhost=${RELAYHOST}" \
"mynetworks=127.0.0.0/8 ${RELAYNETWORKS}" \
"mydomain=${MYDOMAIN}" \
"smtp_bind_address=${SRCIP}" \
"smtp_sasl_auth_enable = yes" \
"smtp_sasl_security_options = noanonymous" \
"smtp_sasl_password_maps = hash:${config_directory}/sasl_passwd" \
"smtp_use_tls = yes" \
"smtp_tls_security_level = encrypt" \
"smtp_tls_note_starttls_offer = yes" \
"smtp_tls_CAfile = /${cafile}"

echo "Writing ${config_directory}/sasl_passwd"
printf "%s %s:%s\n" ${RELAYHOST} ${SMTPUSER} ${SMTPPASSWD} > ${config_directory}/sasl_passwd
postmap hash:${config_directory}/sasl_passwd
sed -r -i "s/^[#]root:.*/root: ${ROOTMAIL}/" ${config_directory}/aliases
newaliases
