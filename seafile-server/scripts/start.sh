#!/bin/bash

source /scripts/utils.sh
trap 'sigterm' SIGTERM

rm -f /tmp/gc_active

gc_cron
start_server &
start_socat &
logger &

wait -n

while [ -f /tmp/gc_active ]; do
    sleep 10
done

exit $?