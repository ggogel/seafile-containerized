#!/bin/bash

function start_seahub {
    /scripts/create_data_links.sh
    echo "{ \"email\": \"${SEAFILE_ADMIN_EMAIL}\",\"password\": \"${SEAFILE_ADMIN_PASSWORD}\"}" | tee /opt/seafile/conf/admin.txt
    #/opt/seafile/seafile-server-latest/seahub.sh start
    python3 /opt/seafile/seafile-server-latest/check_init_admin.py
    python3 /opt/seafile/seafile-server-latest/seahub/manage.py runserver 0.0.0.0:8000
}

function start_socat {
    mkdir -p /opt/seafile/seafile-server-latest/runtime
    socat -d -d UNIX-LISTEN:/opt/seafile/seafile-server-latest/runtime/seafile.sock,fork UDP:seafile-server:8001
}

function keep_running {
    while true; do
        tail -f /dev/null & wait ${!}
    done
}

start_socat &
start_seahub &
keep_running