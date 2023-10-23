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
    while true; do
        while ! nc -z ${SEAFILE_SERVER_HOSTNAME} 8001 2>/dev/null; do
            sleep 1
        done
        echo "Starting socat..."
        socat -d -d UNIX-LISTEN:/opt/seafile/seafile-server-latest/runtime/seafile.sock,fork,unlink-early TCP:${SEAFILE_SERVER_HOSTNAME}:8001,forever,keepalive,keepidle=10,keepintvl=10,keepcnt=2
    done
}

function watch_server {
    while true; do
        sleep 2
        if ! nc -z ${SEAFILE_SERVER_HOSTNAME} 8082 2>/dev/null; then
            /opt/seafile/seafile-server-latest/seahub.sh stop
            while ! nc -z ${SEAFILE_SERVER_HOSTNAME} 8082 2>/dev/null; do
                sleep 1
            done
            start_seahub &
        fi
    done
}

function logger {
    tail -f /opt/seafile/logs/seahub.log | tee /proc/1/fd/1
}

function keep_running {
    while true; do
        tail -f /dev/null & wait ${!}
    done
}

start_socat &
init_seahub
start_seahub &
watch_server &
logger
keep_running
