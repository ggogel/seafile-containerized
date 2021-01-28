#!/bin/bash

function sigterm {
    stop_socat
    stop_server
    exit 0
}

function start_server {
    /scripts/create_data_links.sh
    python3 /scripts/start.py
}

function stop_server {
    echo "Stopping seafile server..."
    /opt/seafile/seafile-server-latest/seafile.sh stop
}

function start_socat {
    echo "Waiting for SeaRPC socket..."
    while [ ! -S /opt/seafile/seafile-server-latest/runtime/seafile.sock ]; do
        sleep 1
    done
    socat -d -d UDP-LISTEN:8001,fork,reuseaddr UNIX:/opt/seafile/seafile-server-latest/runtime/seafile.sock,forever
}

function stop_socat {
    echo "Stopping socat..."
    ps aux | grep '[s]ocat' | awk '{print $2}' | xargs kill -15 |& tee /dev/null
    sleep 5
    ps aux | grep '[s]ocat' | awk '{print $2}' | xargs kill -9 |& tee /dev/null
}

function keep_running {
    while true; do
        tail -f /dev/null & wait ${!}
    done
}

trap 'sigterm' SIGTERM
start_server &
start_socat &
keep_running