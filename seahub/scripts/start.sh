#!/bin/bash

/scripts/create_data_links.sh

mkdir -p /opt/seafile/seafile-server-latest/runtime
socat -d -d UNIX-LISTEN:/opt/seafile/seafile-server-latest/runtime/seafile.sock,fork TCP:seafile-server:8001,forever,keepalive,keepidle=10,keepintvl=10,keepcnt=2  &

python3 /opt/seafile/seafile-server-latest/seahub/manage.py runserver 0.0.0.0:8000

