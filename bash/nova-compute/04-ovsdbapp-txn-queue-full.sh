#!/bin/bash -eu
#
# Description: capture number of ovsdbapp transcation queue full errors.
#
. $SCRIPT_ROOT/lib.sh

SCRIPT_HEADER ovsdbapp.backend.ovs_idl.command

expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ cause: TXN queue is full/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ cause: TXN queue is full/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER ovsdbapp-txn-queue-full-events
