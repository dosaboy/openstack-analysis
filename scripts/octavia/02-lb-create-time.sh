#!/bin/bash -eu
#
# Description: loadbalancer create time
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER octavia.controller.worker.v1.tasks.database_tasks

expr1="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME [0-9]+ .+ \[-\] Creating load balancer '([a-z0-9-]+)'\.+"
expr2="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Mark ACTIVE in DB for load balancer id: ([a-z0-9-]+)\$"
process_log_deltas $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER lb-create-time
