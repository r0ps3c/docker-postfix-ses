#!/bin/sh
set -e
MONITOR_INTERVAL=10 # seconds

/opt/postfix/scripts/write-config.sh $@
/usr/libexec/postfix/master -w

# consider clean shutdown by trapping signals?

while pkill -0 master; do
	sleep $MONITOR_INTERVAL
done
