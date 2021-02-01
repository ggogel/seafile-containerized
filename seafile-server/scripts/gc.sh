#!/bin/bash
set -e
source /scripts/utils.sh
SEAFILE_DIR=/opt/seafile/seafile-server-latest

if [[ $SEAFILE_SERVER != *"pro"* ]]; then
    echo "Seafile CE: Stop Seafile to perform offline garbage collection."
    stop_socat
    $SEAFILE_DIR/seafile.sh stop
    echo "Waiting for the server to shut down properly..."
    sleep 5
else
    echo "Seafile Pro: Perform online garbage collection."
fi

(
    set +e
    $SEAFILE_DIR/seaf-gc.sh "$@" | tee -a /opt/seafile/logs/gc.log
    exit "${PIPESTATUS[0]}"
) gc_exit_code=$?

if [[ $SEAFILE_SERVER != *"pro"* ]]; then
    echo "Seafile CE: Offline garbage collection completed. Starting Seafile."
    sleep 3
    $SEAFILE_DIR/seafile.sh start
    start_socat
fi
exit $gc_exit_code
