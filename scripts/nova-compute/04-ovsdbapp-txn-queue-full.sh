#!/bin/bash -eu
#
# Description: capture number of ovsdbapp transcation queue full errors.
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER ovsdbapp.backend.ovs_idl.command

expr1="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ cause: TXN queue is full"
expr2="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ cause: TXN queue is full"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" 1 true

SCRIPT_FOOTER ovsdbapp-txn-queue-full-events
