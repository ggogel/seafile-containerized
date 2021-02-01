#!/bin/bash

source /scripts/utils.sh
trap 'sigterm' SIGTERM

gc_cron &
start_server &
start_socat &
logger &
keep_running