#!/bin/bash -eu
#
# Description: loadbalancer create time
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for octavia-worker logs
[[ $LOG =~ octavia-worker.log ]] || exit 0

SCRIPT_HEADER octavia.controller.worker.v1.tasks.database_tasks

seq_start_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME [0-9]+ .+ \[-\] Creating load balancer '([a-z0-9-]+)'\.+"
seq_end_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Mark ACTIVE in DB for load balancer id: ([a-z0-9-]+)\$"
process_log_deltas $LOG $DATA_TMP $CSV_PATH "$seq_start_expr" "$seq_end_expr" true

SCRIPT_FOOTER lb-create-time
