#!/bin/bash
source /scripts/utils.sh
SEAFILE_DIR=/opt/seafile/seafile-server-latest

if [[ $SEAFILE_SERVER != *"pro"* ]]; then
    echo "Seafile CE: Stop Seafile to perform offline garbage collection."
    stop_socat
    $SEAFILE_DIR/seafile.sh stop
    echo "Waiting for the server to shut down properly..."
    sleep 30
    echo "Kill remaining processes with SIGKILL signal."
    sig_kill_all
else
    echo "Seafile Pro: Perform online garbage collection."
fi

$SEAFILE_DIR/seaf-gc.sh "$@"

if [[ $SEAFILE_SERVER != *"pro"* ]]; then
    echo "Seafile CE: Offline garbage collection completed. Starting Seafile."
    sleep 3
    $SEAFILE_DIR/seafile.sh start
    start_socat &
fi
