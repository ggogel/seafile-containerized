#!/bin/bash
source /scripts/utils.sh
SEAFILE_DIR=/opt/seafile/seafile-server-latest

if [[ $SEAFILE_SERVER != *"pro"* ]]; then
    touch /tmp/gc_active
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
    echo "Seafile CE: Offline garbage collection completed. Exiting..."
    echo "Set the restart policy of this container to unless-stopped to restart it automatically after garbage collection."
    rm -f /tmp/gc_active
fi
