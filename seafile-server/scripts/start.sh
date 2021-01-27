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
    while [ ! -S /opt/seafile/seafile-server-latest/runtime/seafile.sock ]; do
        echo "Waiting for SeaRPC socket..."
        sleep 1
    done
    #socat -d -d TCP-LISTEN:8001,fork,reuseaddr UNIX:/opt/seafile/seafile-server-latest/runtime/seafile.sock,forever
}

function stop_socat {
    echo "Stopping socat..."
    ps aux | grep '[s]ocat' | awk '{print $2}' | xargs kill -15 > /dev/null
    sleep 2
    if [ -z $(ps aux | grep '[s]ocat')]; then
        ps aux | grep '[s]ocat' | awk '{print $2}' | xargs kill -9 > /dev/null
    fi
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