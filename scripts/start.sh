#!/bin/sh
set -e

cleanup () {
	/usr/sbin/postfix stop
}

trap cleanup INT QUIT TERM 
/opt/postfix/scripts/update-config.sh $@
/usr/libexec/postfix/master -w

# required as the sleep ignores signals
(sleep INF)&     
wait $!
