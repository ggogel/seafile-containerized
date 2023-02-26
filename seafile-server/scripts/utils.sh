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
    socat -d TCP-LISTEN:8001,fork,reuseaddr UNIX:/opt/seafile/seafile-server-latest/runtime/seafile.sock,forever
}

function stop_socat {
    echo "Stopping socat..."
    pkill -15 socat
    sleep 5
    pkill -9 socat
}

function gc_cron {
    if [[ ! -z $GC_CRON ]]; then
        echo "Scheduling garbage collection..."
        (crontab -l ; echo "$GC_CRON /scripts/gc.sh >> /opt/seafile/logs/gc.log 2>&1") | crontab
        service cron start
    fi
}

function logger {
    tail -f /opt/seafile/logs/common.log | tee
}

function keep_running {
    while true; do
        tail -f /dev/null & wait ${!}
    done
}

function sig_kill_all () {
    pkill -SIGKILL -f "seaf-server -c ${default_ccnet_conf_dir}"
    pkill -SIGKILL -f "fileserver -c ${default_ccnet_conf_dir}"
    pkill -SIGKILL -f "seafevents.main"
    pkill -SIGKILL -f "convert_server.py"
    pkill -SIGKILL -f "soffice.*--invisible --nocrashreport"
    pkill -SIGKILL -f  "wsgidav.server.server_cli"
    pkill -SIGKILL -f  "notification-server -c ${central_config_dir}"
    pkill -SIGKILL -f  "seafile-monitor.sh"
}