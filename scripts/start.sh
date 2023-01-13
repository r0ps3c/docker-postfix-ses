#!/bin/sh

set -e

cleanup () {
	/usr/sbin/postfix stop
}

/opt/postfix/scripts/update-config.sh $@

if [ "${POSTFIX_CHECK}" == "1" ]
then
	if /usr/sbin/postfix check
	then
		echo "ok"
	else
		echo "failed: $?"
	fi
else
	trap cleanup INT QUIT TERM 
	/usr/libexec/postfix/master -w

	# required as the sleep ignores signals
	(sleep INF)&     
	wait $!
fi
