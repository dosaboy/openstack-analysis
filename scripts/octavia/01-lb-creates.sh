#!/bin/bash -eu
#
# Description: loadbalancer creates
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for octavia-worker logs
[[ $LOG =~ octavia-worker.log ]] || exit 0

SCRIPT_HEADER octavia.controller.queue.v1.endpoints

row_expr="s/^$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE \[-\] Creating load balancer '\S+'.../\1/p"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true lb-creates

SCRIPT_FOOTER lb-creates
