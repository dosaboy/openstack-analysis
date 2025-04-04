#!/bin/bash -eu
#
# Description: loadbalancer creates
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER octavia.controller.queue.v1.endpoints

expr1="s/^$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE \[-\] Creating load balancer '\S+'.../\1/p"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$expr1" true lb-creates

SCRIPT_FOOTER lb-creates
