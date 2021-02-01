#!/bin/bash

source /scripts/utils.sh

trap 'sigterm' SIGTERM
start_server &
start_socat &
keep_running