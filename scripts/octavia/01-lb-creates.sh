#!/bin/bash -eu
#
# Description: loadbalancer creates
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for octavia-worker logs
[[ $LOG =~ octavia-worker.log ]] || exit 0

SCRIPT_HEADER octavia.controller.queue.v1.endpoints

y_label=lb-creates
row_expr="^$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE \[-\] Creating load balancer '\S+'..."
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $y_label

SCRIPT_FOOTER $y_label
