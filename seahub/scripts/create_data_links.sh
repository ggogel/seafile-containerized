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

if [[ ! -e /shared/seafile/conf/seahub.conf ]]; then
    mv /opt/seafile/seafile-server-latest/runtime/seahub.conf /shared/seafile/conf/seahub.conf
fi

rm -f /opt/seafile/seafile-server-latest/runtime/seahub.conf
ln -sf /shared/seafile/conf/seahub.conf /opt/seafile/seafile-server-latest/runtime/seahub.conf

mkdir -p /shared/runtime
rm -rf /opt/seafile/seafile-server-latest/runtime
ln -sf /shared/runtime /opt/seafile/seafile-server-latest/runtime
