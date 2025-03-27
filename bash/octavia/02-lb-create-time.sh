#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

SCRIPT_HEADER ctavia.controller.queue.v1.endpoints

expr1="^$EXPR_LOG_DATE_GROUP_TIME [0-9]+ .+ \[-\] Creating load balancer '([a-z0-9-]+)'\.+"
expr2='^$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Mark ACTIVE in DB for load balancer id: ([a-z0-9-]+)$'
process_log_deltas $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER lb-creates
