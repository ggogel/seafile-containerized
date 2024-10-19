#!/bin/bash

function init_seahub {
    /scripts/create_data_links.sh
    echo "{ \"email\": \"${SEAFILE_ADMIN_EMAIL}\",\"password\": \"${SEAFILE_ADMIN_PASSWORD}\"}" >/opt/seafile/conf/admin.txt
    sed -i 's@bind =.*@bind = "0.0.0.0:8000"@' /opt/seafile/conf/gunicorn.conf.py
    /opt/seafile/seafile-server-latest/conf/seahub_settings.py
}

function init_csrf {
    CONFIG_FILE="/opt/seafile/conf/seahub_settings.py"

    # Check if CSRF_TRUSTED_ORIGINS is already set
    if grep -q '^CSRF_TRUSTED_ORIGINS' "$CONFIG_FILE"; then
        echo "CSRF_TRUSTED_ORIGINS is already set in $CONFIG_FILE"
        return 0
    fi

    # Read SERVICE_URL from the config file
    SERVICE_URL=$(grep '^SERVICE_URL' "$CONFIG_FILE" | sed 's/.*= *"//;s/"//')

    # If SERVICE_URL is empty, exit with error
    if [ -z "$SERVICE_URL" ]; then
        echo "SERVICE_URL is not set in $CONFIG_FILE"
        return 1
    fi

    # Append CSRF_TRUSTED_ORIGINS line to the config file
    echo "CSRF_TRUSTED_ORIGINS = ['$SERVICE_URL']" >> "$CONFIG_FILE"
    echo "CSRF_TRUSTED_ORIGINS has been set to ['$SERVICE_URL'] in $CONFIG_FILE"
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
init_csrf
start_socat &
sleep 1
start_seahub
watch_server &
watch_seahub &
logger &

wait -n 

exit $?