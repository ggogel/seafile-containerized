#!/bin/bash

source /scripts/utils.sh

gc_cron &
start_server &
start_socat &
keep_running