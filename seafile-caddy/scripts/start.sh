#!/bin/bash

if [ "$SWARM_DNS" = true ]; then
    /scripts/swarm-dns.sh &
fi

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

wait -n

exit $?