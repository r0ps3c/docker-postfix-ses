#!/bin/sh
set -e
if [ "$#" -ne 7 ]
then
	echo "invalid args supplied: \"$@\""
	echo "usage: $0 <RELAYHOST> <RELAYNETWORKS> <MYDOMAIN> <SRCIP> <SMTPUSER> <SMTPPASSWD> <ROOTMAIL>"
	exit 1
fi

CONFIGDIR=`postconf -h config_directory`
RELAYHOST=$1
RELAYNETWORKS=$2
MYDOMAIN=$3
SRCIP=$4
SMTPUSER=$5
SMTPPASSWD=$6
ROOTMAIL=$7

echo "Updating ${CONFIGDIR}/main.cf.template -> ${CONFIGDIR}/main.cf"
sed -e "s/<--RELAYHOST-->/${RELAYHOST}/g;s/<--RELAYNETWORKS-->/${RELAYNETWORKS}/g;s/<--MYDOMAIN-->/${MYDOMAIN}/;s/<--SRCIP-->/${SRCIP}/g" ${CONFIGDIR}/main.cf.template > ${CONFIGDIR}/main.cf

SASLPASSWD=$(postconf -h smtp_sasl_password_maps|awk -F: '{print $2}')

echo "Writing ${SASLPASSWD}"
printf "%s %s:%s\n" ${RELAYHOST} ${SMTPUSER} ${SMTPPASSWD} >> ${SASLPASSWD}
postmap hash:${SASLPASSWD}
sed -r -i "s/^[#]root:.*/root: ${ROOTMAIL}/" ${CONFIGDIR}/aliases
newaliases
