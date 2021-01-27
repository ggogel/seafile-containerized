#!/bin/bash

set -e
set -o pipefail

if [[ $SEAFILE_BOOTSRAP != "" ]]; then
    exit 0
fi

if [[ $TIME_ZONE != "" ]]; then
    time_zone=/usr/share/zoneinfo/$TIME_ZONE
    if [[ ! -e $time_zone ]]; then
        echo "invalid time zone"
        exit 1
    else
        ln -snf $time_zone /etc/localtime
        echo "$TIME_ZONE" > /etc/timezone
    fi
fi

while [[ ! -e /shared/seafile/conf || ! -e /shared/seafile/ccnet || ! -e /shared/seafile/seafile-data || ! -e /shared/seafile/seahub-data ]]; do
        echo "Waiting for initialization by seafile-server..."
        sleep 5
done

dirs=(
    conf
    ccnet
    seafile-data
    seahub-data
    pro-data
    seafile-license.txt
)

for d in ${dirs[*]}; do
    src=/shared/seafile/$d
    if [[ -e $src ]]; then
        rm -rf /opt/seafile/$d && ln -sf $src /opt/seafile
    fi
done

#ln -sf /shared/seafile/seahub-data /opt/seafile/seafile-server-latest/seahub-data
rm -rf /opt/seafile/seafile-server-latest/seahub/media/avatars
rm -rf /opt/seafile/seafile-server-latest/seahub/media/custom
ln -sf /shared/seafile/seahub-data/avatars /opt/seafile/seafile-server-latest/seahub/media
ln -sf /shared/seafile/seahub-data/custom /opt/seafile/seafile-server-latest/seahub/media

if [[ ! -e /shared/seafile/conf/seahub.conf ]]; then
    mv /opt/seafile/seafile-server-latest/runtime/seahub.conf /shared/seafile/conf/seahub.conf
fi
rm -f /opt/seafile/seafile-server-latest/runtime/seahub.conf
ln -sf /shared/seafile/conf/seahub.conf /opt/seafile/seafile-server-latest/runtime/seahub.conf