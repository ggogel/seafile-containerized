#!/bin/bash

function init_seahub {
    /scripts/create_data_links.sh
    echo "{ \"email\": \"${SEAFILE_ADMIN_EMAIL}\",\"password\": \"${SEAFILE_ADMIN_PASSWORD}\"}" >/opt/seafile/conf/admin.txt
    sed -i 's@bind =.*@bind = "0.0.0.0:8000"@' /opt/seafile/conf/gunicorn.conf.py
}

function start_seahub {
    /opt/seafile/seafile-server-latest/seahub.sh start
}

function start_socat {
    mkdir -p /opt/seafile/seafile-server-latest/runtime
    if ! nc -z ${SEAFILE_SERVER_HOSTNAME} 8001 2>/dev/null; then
        echo "Failed to establish socat bridge with seafile-server on port 8001. Terminating..."
        exit
    fi
    echo "Starting socat..."
    socat -d -d UNIX-LISTEN:/opt/seafile/seafile-server-latest/runtime/seafile.sock,fork,unlink-early TCP:${SEAFILE_SERVER_HOSTNAME}:8001,forever,keepalive,keepidle=10,keepintvl=10,keepcnt=2
    echo "Socat process was stopped. Exiting container..."
}

function watch_server {
    while true; do
        sleep 1
        if ! nc -z ${SEAFILE_SERVER_HOSTNAME} 8082 2>/dev/null; then
            echo "Lost connection to seafile-server. Stopping seahub..."
            /opt/seafile/seafile-server-latest/seahub.sh stop
        fi
    done
}

function watch_seahub {
    while true; do
        sleep 1
        if ! pgrep -f "seahub.wsgi:application" >/dev/null; then
            echo "Seahub process was stopped. Exiting container..."
            break
        fi
    done
}

function logger {
    tail -f /opt/seafile/logs/seahub.log | tee
}

init_seahub
start_seahub

start_socat &
watch_server &
watch_seahub &
logger &

wait -n 

exit $?